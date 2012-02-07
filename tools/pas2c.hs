module Pas2C where

import Text.PrettyPrint.HughesPJ
import Data.Maybe
import Data.Char
import Text.Parsec.Prim hiding (State)
import Control.Monad.State
import System.IO
import System.Directory
import Control.Monad.IO.Class
import PascalPreprocessor
import Control.Exception
import System.IO.Error
import qualified Data.Map as Map
import Data.List (find)

import PascalParser
import PascalUnitSyntaxTree


type Record = (String, (String, BaseType))
data RenderState = RenderState 
    {
        currentScope :: [Record],
        lastType :: BaseType,
        namespaces :: Map.Map String [Record]
    }

pas2C :: String -> IO ()
pas2C fn = do
    setCurrentDirectory "../hedgewars/"
    s <- flip execStateT initState $ f fn
    renderCFiles s
    where
    printLn = liftIO . hPutStrLn stderr
    print = liftIO . hPutStr stderr
    initState = Map.empty
    f :: String -> StateT (Map.Map String PascalUnit) IO ()
    f fileName = do
        processed <- gets $ Map.member fileName
        unless processed $ do
            print ("Preprocessing '" ++ fileName ++ ".pas'... ")
            fc' <- liftIO 
                $ tryJust (guard . isDoesNotExistError) 
                $ preprocess (fileName ++ ".pas")
            case fc' of
                (Left a) -> do
                    modify (Map.insert fileName (System []))
                    printLn "doesn't exist"
                (Right fc) -> do
                    print "ok, parsing... "
                    let ptree = parse pascalUnit fileName fc
                    case ptree of
                         (Left a) -> do
                            liftIO $ writeFile "preprocess.out" fc
                            printLn $ show a ++ "\nsee preprocess.out for preprocessed source"
                            fail "stop"
                         (Right a) -> do
                            printLn "ok"
                            modify (Map.insert fileName a)
                            mapM_ f (usesFiles a)


renderCFiles :: Map.Map String PascalUnit -> IO ()
renderCFiles units = do
    let u = Map.toList units
    let nss = Map.map (toNamespace nss) units
    mapM_ (toCFiles nss) u
    where
    toNamespace :: Map.Map String [Record] -> PascalUnit -> [Record]
    toNamespace nss (System tvs) = 
        currentScope $ execState (mapM_ (tvar2C True) tvs) (RenderState [] BTUnknown nss)
    toNamespace _ (Program {}) = []
    toNamespace nss (Unit _ interface _ _ _) = 
        currentScope $ execState (interface2C interface) (RenderState [] BTUnknown nss)

   
toCFiles :: Map.Map String [Record] -> (String, PascalUnit) -> IO ()
toCFiles _ (_, System _) = return ()
toCFiles ns p@(fn, pu) = do
    hPutStrLn stderr $ "Rendering '" ++ fn ++ "'..."
    toCFiles' p
    where
    toCFiles' (fn, p@(Program {})) = writeFile (fn ++ ".c") $ (render2C initialState . pascal2C) p
    toCFiles' (fn, (Unit _ interface implementation _ _)) = do
        let (a, s) = runState (interface2C interface) initialState
        writeFile (fn ++ ".h") $ "#pragma once\n" ++ (render a)
        writeFile (fn ++ ".c") $ (render2C s . implementation2C) implementation
    initialState = RenderState [] BTUnknown ns

    render2C :: RenderState -> State RenderState Doc -> String
    render2C a = render . flip evalState a

usesFiles :: PascalUnit -> [String]
usesFiles (Program _ (Implementation uses _) _) = "pas2cSystem" : uses2List uses
usesFiles (Unit _ (Interface uses1 _) (Implementation uses2 _) _ _) = "pas2cSystem" : uses2List uses1 ++ uses2List uses2
usesFiles (System {}) = []


pascal2C :: PascalUnit -> State RenderState Doc
pascal2C (Unit _ interface implementation init fin) =
    liftM2 ($+$) (interface2C interface) (implementation2C implementation)
    
pascal2C (Program _ implementation mainFunction) = do
    impl <- implementation2C implementation
    main <- tvar2C True 
        (FunctionDeclaration (Identifier "main" BTInt) (SimpleType $ Identifier "int" BTInt) [] (Just (TypesAndVars [], mainFunction)))
    return $ impl $+$ main

    
    
interface2C :: Interface -> State RenderState Doc
interface2C (Interface uses tvars) = liftM2 ($+$) (uses2C uses) (typesAndVars2C True tvars)

implementation2C :: Implementation -> State RenderState Doc
implementation2C (Implementation uses tvars) = liftM2 ($+$) (uses2C uses) (typesAndVars2C True tvars)


typesAndVars2C :: Bool -> TypesAndVars -> State RenderState Doc
typesAndVars2C b (TypesAndVars ts) = liftM vcat $ mapM (tvar2C b) ts

uses2C :: Uses -> State RenderState Doc
uses2C uses@(Uses unitIds) = do
    mapM_ injectNamespace (Identifier "pas2cSystem" undefined : unitIds)
    mapM_ (id2C True) unitIds
    return $ vcat . map (\i -> text $ "#include \"" ++ i ++ ".h\"") $ uses2List uses
    where
    injectNamespace (Identifier i _) = do
        getNS <- gets (flip Map.lookup . namespaces)
        let f = flip (foldl (\a b -> b:a)) (fromMaybe [] (getNS i))
        modify (\s -> s{currentScope = f $ currentScope s})

uses2List :: Uses -> [String]
uses2List (Uses ids) = map (\(Identifier i _) -> i) ids


id2C :: Bool -> Identifier -> State RenderState Doc
id2C True (Identifier i t) = do
    modify (\s -> s{currentScope = (map toLower i, (i, t)) : currentScope s})
    return $ text i
id2C False (Identifier i t) = do
    let i' = map toLower i
    v <- gets $ find (\(a, _) -> a == i') . currentScope
    ns <- gets currentScope
    modify (\s -> s{lastType = t})
    if isNothing v then 
        error $ "Not defined: '" ++ i' ++ "'\n" ++ show ns
        else 
        return . text . fst . snd . fromJust $ v

id2CTyped :: BaseType -> Identifier -> State RenderState Doc
id2CTyped BTUnknown i = do
    ns <- gets currentScope
    error $ "id2CTyped: type BTUnknown for " ++ show i ++ "\n" ++ show ns
id2CTyped bt (Identifier i _) = id2C True (Identifier i bt)


resolveType :: TypeDecl -> State RenderState BaseType
resolveType st@(SimpleType (Identifier i _)) = do
    let i' = map toLower i
    v <- gets $ find (\(a, _) -> a == i') . currentScope
    if isJust v then return . snd . snd $ fromJust v else return $ f i'
    where
    f "integer" = BTInt
    f "pointer" = BTPointerTo BTVoid
    f "boolean" = BTBool
    f "float" = BTFloat
    f "char" = BTChar
    f "string" = BTString
    f _ = error $ "Unknown system type: " ++ show st
resolveType (PointerTo t) = liftM BTPointerTo $ resolveType t
resolveType (RecordType tv mtvs) = do
    tvs <- mapM f (concat $ tv : fromMaybe [] mtvs)
    return . BTRecord . concat $ tvs
    where
        f :: TypeVarDeclaration -> State RenderState [(String, BaseType)]
        f (VarDeclaration _ (ids, td) _) = mapM (\(Identifier i _) -> liftM ((,) i) $ resolveType td) ids
resolveType (ArrayDecl (Just _) t) = liftM (BTArray BTInt) $ resolveType t
resolveType (ArrayDecl Nothing t) = liftM (BTArray BTInt) $ resolveType t
resolveType (FunctionType _ _) = return BTFunction
resolveType (DeriveType _) = return BTInt
resolveType (String _) = return BTString
--resolveType UnknownType = return BTUnknown    
resolveType a = error $ "resolveType: " ++ show a
    
    
tvar2C :: Bool -> TypeVarDeclaration -> State RenderState Doc
tvar2C _ (FunctionDeclaration name returnType params Nothing) = do
    t <- type2C returnType 
    p <- liftM hcat $ mapM (tvar2C False) params
    n <- id2C True name
    return $ t <+> n <> parens p <> text ";"
    
tvar2C True (FunctionDeclaration name returnType params (Just (tvars, phrase))) = do
    t <- type2C returnType 
    p <- liftM hcat $ mapM (tvar2C False) params
    ph <- liftM2 ($+$) (typesAndVars2C False tvars) (phrase2C' phrase)
    n <- id2C True name
    return $ 
        t <+> n <> parens p
        $+$
        text "{" 
        $+$ 
        nest 4 ph
        $+$
        text "}"
    where
    phrase2C' (Phrases p) = liftM vcat $ mapM phrase2C p
    phrase2C' p = phrase2C p
    
tvar2C False (FunctionDeclaration (Identifier name _) _ _ _) = error $ "nested functions not allowed: " ++ name

tvar2C _ td@(TypeDeclaration i' t) = do
    tb <- resolveType t
    i <- id2CTyped tb i'
    tp <- type2C t
    return $ text "type" <+> i <+> tp <> text ";"
    
tvar2C _ (VarDeclaration isConst (ids, t) mInitExpr) = do
    t' <- type2C t
    tb <- resolveType t
    i <- mapM (id2CTyped tb) ids
    ie <- initExpr mInitExpr
    return $ if isConst then text "const" else empty
        <+> t'
        <+> (hsep . punctuate (char ',') $ i)
        <+> ie
        <> text ";"
    where
    initExpr Nothing = return $ empty
    initExpr (Just e) = liftM (text "=" <+>) (initExpr2C e)
    
tvar2C f (OperatorDeclaration op _ ret params body) = 
    tvar2C f (FunctionDeclaration (Identifier ("<op " ++ op ++ ">") BTUnknown) ret params body)

    
initExpr2C :: InitExpression -> State RenderState Doc
initExpr2C (InitBinOp op expr1 expr2) = do
    e1 <- initExpr2C expr1
    e2 <- initExpr2C expr2
    o <- op2C op
    return $ parens $ e1 <+> o <+> e2
initExpr2C (InitNumber s) = return $ text s
initExpr2C (InitFloat s) = return $ text s
initExpr2C (InitHexNumber s) = return $ text "0x" <> (text . map toLower $ s)
initExpr2C (InitString s) = return $ doubleQuotes $ text s 
initExpr2C (InitReference i) = id2C False i
initExpr2C _ = return $ text "<<expression>>"


type2C :: TypeDecl -> State RenderState Doc
type2C UnknownType = return $ text "void"
type2C (String l) = return $ text $ "string" ++ show l
type2C (SimpleType i) = id2C False i
type2C (PointerTo (SimpleType i)) = liftM (<> text "*") $ id2C True i
type2C (PointerTo t) = liftM (<> text "*") $ type2C t
type2C (RecordType tvs union) = do
    t <- mapM (tvar2C False) tvs
    return $ text "{" $+$ (nest 4 . vcat $ t) $+$ text "}"
type2C (RangeType r) = return $ text "<<range type>>"
type2C (Sequence ids) = do
    mapM_ (id2C True) ids
    return $ text "<<sequence type>>"
type2C (ArrayDecl r t) = return $ text "<<array type>>"
type2C (Set t) = return $ text "<<set>>"
type2C (FunctionType returnType params) = return $ text "<<function>>"
type2C (DeriveType _) = return $ text "<<type derived from constant literal>>"

phrase2C :: Phrase -> State RenderState Doc
phrase2C (Phrases p) = do
    ps <- mapM phrase2C p
    return $ text "{" $+$ (nest 4 . vcat $ ps) $+$ text "}"
phrase2C (ProcCall f@(FunCall {}) []) = liftM (<> semi) $ ref2C f
phrase2C (ProcCall ref params) = do
    r <- ref2C ref
    ps <- mapM expr2C params
    return $ r <> parens (hsep . punctuate (char ',') $ ps) <> semi
phrase2C (IfThenElse (expr) phrase1 mphrase2) = do
    e <- expr2C expr
    p1 <- (phrase2C . wrapPhrase) phrase1
    el <- elsePart
    return $ 
        text "if" <> parens e $+$ p1 $+$ el
    where
    elsePart | isNothing mphrase2 = return $ empty
             | otherwise = liftM (text "else" $$) $ (phrase2C . wrapPhrase) (fromJust mphrase2)
phrase2C (Assignment ref expr) = do
    r <- ref2C ref 
    e <- expr2C expr
    return $
        r <> text " = " <> e <> semi
phrase2C (WhileCycle expr phrase) = do
    e <- expr2C expr
    p <- phrase2C $ wrapPhrase phrase
    return $ text "while" <> parens e $$ p
phrase2C (SwitchCase expr cases mphrase) = do
    e <- expr2C expr
    cs <- mapM case2C cases
    return $ 
        text "switch" <> parens e <> text "of" $+$ (nest 4 . vcat) cs
    where
    case2C :: ([InitExpression], Phrase) -> State RenderState Doc
    case2C (e, p) = do
        ie <- mapM initExpr2C e
        ph <- phrase2C p
        return $ 
            text "case" <+> parens (hsep . punctuate (char ',') $ ie) <> char ':' <> nest 4 (ph $+$ text "break;")
phrase2C (WithBlock ref p) = do
    r <- ref2C ref 
    ph <- phrase2C $ wrapPhrase p
    return $ text "namespace" <> parens r $$ ph
phrase2C (ForCycle i' e1' e2' p) = do
    i <- id2C False i'
    e1 <- expr2C e1'
    e2 <- expr2C e2'
    ph <- phrase2C (wrapPhrase p)
    return $ 
        text "for" <> (parens . hsep . punctuate (char ';') $ [i <+> text "=" <+> e1, i <+> text "<=" <+> e2, text "++" <> i])
        $$
        ph
phrase2C (RepeatCycle e' p') = do
    e <- expr2C e'
    p <- phrase2C (Phrases p')
    return $ text "do" <+> p <+> text "while" <> parens (text "!" <> parens e)
phrase2C NOP = return $ text ";"


wrapPhrase p@(Phrases _) = p
wrapPhrase p = Phrases [p]


expr2C :: Expression -> State RenderState Doc
expr2C (Expression s) = return $ text s
expr2C (BinOp op expr1 expr2) = do
    e1 <- expr2C expr1
    e2 <- expr2C expr2
    o <- op2C op
    return $ parens $ e1 <+> o <+> e2
expr2C (NumberLiteral s) = return $ text s
expr2C (FloatLiteral s) = return $ text s
expr2C (HexNumber s) = return $ text "0x" <> (text . map toLower $ s)
expr2C (StringLiteral s) = return $ doubleQuotes $ text s 
expr2C (Reference ref) = ref2C ref
expr2C (PrefixOp op expr) = liftM2 (<+>) (op2C op) (expr2C expr)
expr2C Null = return $ text "NULL"
expr2C (BuiltInFunCall params ref) = do
    r <- ref2C ref 
    ps <- mapM expr2C params
    return $ 
        r <> parens (hsep . punctuate (char ',') $ ps)
expr2C _ = return $ text "<<expression>>"


ref2C :: Reference -> State RenderState Doc
ref2C (ArrayElement exprs ref) = do
    r <- ref2C ref 
    es <- mapM expr2C exprs
    return $ r <> (brackets . hcat) (punctuate comma es)
ref2C (SimpleReference name) = id2C False name
ref2C (RecordField (Dereference ref1) ref2) = do
    r1 <- ref2C ref1 
    r2 <- ref2C ref2
    return $ 
        r1 <> text "->" <> r2
ref2C rf@(RecordField ref1 ref2) = do
    r1 <- ref2C ref1
    t <- gets lastType
    case t of
        r@(BTRecord _) -> error $ show r
        a -> error $ "dereferencing from " ++ show a ++ " - " ++ show rf
    r2 <- ref2C ref2
    return $ 
        r1 <> text "." <> r2
ref2C (Dereference ref) = liftM ((parens $ text "*") <>) $ ref2C ref
ref2C (FunCall params ref) = do
    r <- ref2C ref
    ps <- mapM expr2C params
    return $ 
        r <> parens (hsep . punctuate (char ',') $ ps)
ref2C (Address ref) = do
    r <- ref2C ref
    return $ text "&" <> parens r
ref2C (TypeCast t' expr) = do
    t <- id2C False t'
    e <- expr2C expr
    return $ parens t <> e
ref2C (RefExpression expr) = expr2C expr


op2C :: String -> State RenderState Doc
op2C "or" = return $ text "|"
op2C "and" = return $ text "&"
op2C "not" = return $ text "!"
op2C "xor" = return $ text "^"
op2C "div" = return $ text "/"
op2C "mod" = return $ text "%"
op2C "shl" = return $ text "<<"
op2C "shr" = return $ text ">>"
op2C "<>" = return $ text "!="
op2C "=" = return $ text "=="
op2C a = return $ text a

maybeVoid "" = "void"
maybeVoid a = a
