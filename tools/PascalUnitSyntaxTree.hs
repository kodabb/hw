module PascalUnitSyntaxTree where

--import Data.Traversable
import Data.Maybe

data PascalUnit =
    Program Identifier Implementation Phrase
    | Unit Identifier Interface Implementation (Maybe Initialize) (Maybe Finalize)
    | System [TypeVarDeclaration]
    deriving Show
data Interface = Interface Uses TypesAndVars
    deriving Show
data Implementation = Implementation Uses TypesAndVars
    deriving Show
data Identifier = Identifier String BaseType
    deriving Show
data TypesAndVars = TypesAndVars [TypeVarDeclaration]
    deriving Show
data TypeVarDeclaration = TypeDeclaration Identifier TypeDecl
    | VarDeclaration Bool ([Identifier], TypeDecl) (Maybe InitExpression)
    | FunctionDeclaration Identifier TypeDecl [TypeVarDeclaration] (Maybe (TypesAndVars, Phrase))
    | OperatorDeclaration String Identifier TypeDecl [TypeVarDeclaration] (Maybe (TypesAndVars, Phrase))
    deriving Show
data TypeDecl = SimpleType Identifier
    | RangeType Range
    | Sequence [Identifier]
    | ArrayDecl (Maybe Range) TypeDecl
    | RecordType [TypeVarDeclaration] (Maybe [[TypeVarDeclaration]])
    | PointerTo TypeDecl
    | String Integer
    | Set TypeDecl
    | FunctionType TypeDecl [TypeVarDeclaration]
    | UnknownType
    deriving Show
data Range = Range Identifier
           | RangeFromTo InitExpression InitExpression
    deriving Show
data Initialize = Initialize String
    deriving Show
data Finalize = Finalize String
    deriving Show
data Uses = Uses [Identifier]
    deriving Show
data Phrase = ProcCall Reference [Expression]
        | IfThenElse Expression Phrase (Maybe Phrase)
        | WhileCycle Expression Phrase
        | RepeatCycle Expression [Phrase]
        | ForCycle Identifier Expression Expression Phrase
        | WithBlock Reference Phrase
        | Phrases [Phrase]
        | SwitchCase Expression [([InitExpression], Phrase)] (Maybe [Phrase])
        | Assignment Reference Expression
        | NOP
    deriving Show
data Expression = Expression String
    | BuiltInFunCall [Expression] Reference
    | PrefixOp String Expression
    | PostfixOp String Expression
    | BinOp String Expression Expression
    | StringLiteral String
    | CharCode String
    | HexCharCode String
    | NumberLiteral String
    | FloatLiteral String
    | HexNumber String
    | Reference Reference
    | SetExpression [Identifier]
    | Null
    deriving Show
data Reference = ArrayElement [Expression] Reference
    | FunCall [Expression] Reference
    | TypeCast Identifier Expression
    | SimpleReference Identifier
    | Dereference Reference
    | RecordField Reference Reference
    | Address Reference
    | RefExpression Expression
    deriving Show
data InitExpression = InitBinOp String InitExpression InitExpression
    | InitPrefixOp String InitExpression
    | InitReference Identifier
    | InitArray [InitExpression]
    | InitRecord [(Identifier, InitExpression)]
    | InitFloat String
    | InitNumber String
    | InitHexNumber String
    | InitString String
    | InitChar String
    | BuiltInFunction String [InitExpression]
    | InitSet [InitExpression]
    | InitAddress InitExpression
    | InitNull
    | InitRange Range
    | InitTypeCast Identifier InitExpression
    deriving Show

data BaseType = BTUnknown
    | BTChar
    | BTString
    | BTInt
    | BTRecord [(String, BaseType)]
    | BTArray BaseType BaseType
    | BTFunction
    | BTPointerTo BaseType
    | BTSet
    | BTEnum [String]
    | BTVoid
    deriving Show
    

type2BaseType :: TypeDecl -> BaseType
type2BaseType (SimpleType (Identifier s _)) = f s
    where
    f "longint" = BTInt
    f "integer" = BTInt
    f "word" = BTInt
    f "pointer" = BTPointerTo BTVoid
    f _ = BTUnknown
type2BaseType (Sequence ids) = BTEnum $ map (\(Identifier i _) -> i) ids
type2BaseType (RecordType tv mtvs) = BTRecord $ concatMap f (concat $ tv : fromMaybe [] mtvs)
    where
    f (VarDeclaration _ (ids, td) _) = map (\(Identifier i _) -> (i, type2BaseType td)) ids
type2BaseType _ = BTUnknown  
    