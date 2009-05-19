/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2005-2007 Andrey Korotaev <unC0Rr@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#include <QApplication>
#include <QTranslator>
#include <QLocale>
#include <QMessageBox>
#include <QPlastiqueStyle>
#include <QRegExp>
#include <QMap>

#include "hwform.h"
#include "hwconsts.h"

bool checkForDir(const QString & dir)
{
	QDir tmpdir;
	if (!tmpdir.exists(dir))
		if (!tmpdir.mkdir(dir))
		{
			QMessageBox::critical(0,
					QObject::tr("Error"),
					QObject::tr("Cannot create directory %1").arg(dir),
					QObject::tr("OK"));
			return false;
		}
	return true;
}

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

    QStringList arguments = app.arguments();
    QMap<QString, QString> parsedArgs;
    {
        QList<QString>::iterator i = arguments.begin();
        while(i != arguments.end()) {
            QString arg = *i;

            QRegExp opt("--(\\S+)=(.+)");
            if(opt.exactMatch(arg)) {
                parsedArgs[opt.cap(1)] = opt.cap(2);
                i = arguments.erase(i);
            } else {
              ++i;
            }
        }
    }

    if(parsedArgs.contains("data-dir")) {
        QFileInfo f(parsedArgs["data-dir"]);
        if(!f.exists()) {
            qWarning() << "WARNING: Cannot open DATA_PATH=" << f.absoluteFilePath();
        }
        *cDataDir = f.absoluteFilePath();
    }

	app.setStyle(new QPlastiqueStyle);
	
	QDateTime now = QDateTime::currentDateTime();
	QDateTime zero;
	srand(now.secsTo(zero));
	rand();

	Q_INIT_RESOURCE(hedgewars);

	qApp->setStyleSheet
		(QString(
			"HWForm,QDialog{"
				"background-image: url(\":/res/Background.png\");"
				"background-position: bottom center;"
				"background-repeat: repeat-x;"
				"background-color: #870c8f;"
				"}"

			"* {"
				"color: #ffcc00;"
			"}"

			"QLineEdit, QListWidget, QTableView, QTextBrowser, QSpinBox, QComboBox, "
            "QComboBox QAbstractItemView, QMenu::item {"
				"background-color: #0d0544;"
			"}"

			"QPushButton, QListWidget, QTableView, QLineEdit, QHeaderView, "
			"QTextBrowser, QSpinBox, QToolBox, QComboBox, "
            "QComboBox QAbstractItemView, IconedGroupBox, "
			".QGroupBox, GameCFGWidget, TeamSelWidget, SelWeaponWidget, "
            "QTabWidget::pane, QTabBar::tab {"
				"border: solid;"
				"border-width: 3px;"
				"border-color: #ffcc00;"
			"}"

			"QPushButton:hover, QLineEdit:hover, QListWidget:hover, "
			"QSpinBox:hover, QToolBox:hover, QComboBox:hover {"
			    "border-color: yellow;"
			"}"

			"QLineEdit, QListWidget,QTableView, QTextBrowser, "
			"QSpinBox, QToolBox { "
				"border-radius: 12px;"
			"}"

			"QLineEdit, QLabel, QHeaderView, QListWidget, QTableView, "
			"QSpinBox, QToolBox::tab, QComboBox, QComboBox QAbstractItemView, "
			"IconedGroupBox, .QGroupBox, GameCFGWidget, TeamSelWidget, "
            "SelWeaponWidget, QCheckBox, QRadioButton {"
				"font: bold 14px;"
			"}"

			".QGroupBox,GameCFGWidget,TeamSelWidget,SelWeaponWidget {"
				"background-image: url(\":/res/panelbg.png\");"
				"background-position: bottom center;"
				"background-repeat: repeat-x;"
				"border-radius: 16px;"
				"background-color: #040200;"
				"padding: 6px;"
			"}"
/*  Experimenting with PaintOnScreen and border-radius on IconedGroupBox children didn't work out well
			"IconedGroupBox QComboBox, IconedGroupBox QPushButton, IconedGroupBox QLineEdit, "
            "IconedGroupBox QSpinBox {"
				"border-radius: 0;"
			"}"
			"IconedGroupBox, IconedGroupBox *, QTabWidget::pane, QTabBar::tab:selected, QToolBox::tab QWidget{" */
			"IconedGroupBox, QTabWidget::pane, QTabBar::tab:selected, QToolBox::tab QWidget{"
				"background-color: #130f2c;"
			"}"


			"QPushButton {"
				"border-radius: 10px;"
				"background-origin: margin;"
				"background-position: top left;"
				"background-color: #00351d;"
			"}"

			"QPushButton:pressed{"
			    "border-color: white;"
			"}"

			"QHeaderView {"
				"border-radius: 0;"
				"border-width: 0;"
				"border-bottom-width: 3px;"
				"background-color: #00351d;"
			"}"
			"QTableView {"
				"alternate-background-color: #2f213a;"
			"}"

            "QTabBar::tab {"
                 "border-bottom-width: 0;"
                 "border-radius: 0;"
                 "border-top-left-radius: 6px;"
                 "border-top-right-radius: 6px;"
                 "padding: 3px;"
            "}"
            "QTabBar::tab:!selected {"
                 "color: #0d0544;"
                 "background-color: #ffcc00;"
            "}"
			"QSpinBox::up-button{"
				"background: transparent;"
				"width: 16px;"
				"height: 10px;"
			"}"

			"QSpinBox::up-arrow {"
				"image: url(\":/res/spin_up.png\");"
			"}"

			"QSpinBox::down-arrow {"
				"image: url(\":/res/spin_down.png\");"
			"}"

			"QSpinBox::down-button {"
				"background: transparent;"
				"width: 16px;"
				"height: 10px;"
			"}"

			"QComboBox {"
				"border-radius: 15px;"
				"padding: 3px;"
			"}"
			"QComboBox:pressed{"
				"border-color: white;"
			"}"
			"QComboBox::drop-down{"
				"border: transparent;"
				"width: 25px;"
			"}"
			"QComboBox::down-arrow {"
				"image: url(\":/res/dropdown.png\");"
			"}"
			
			"VertScrArea {"
				"background-image: url(\":/res/panelbg.png\");"
				"background-position: bottom center;"
				"background-repeat: repeat-x;"
			"}"
			
			"IconedGroupBox {"
				"border-radius: 16px;"
				"padding: 2px;"
			"}"

			".QGroupBox::title{"
				"subcontrol-origin: margin;"
				"subcontrol-position: top left;"
				//"padding-left: 82px;"
				//"padding-top: 26px;"
				"text-align: left;"
				"}"

			"QCheckBox::indicator:checked{"
				"image: url(\":/res/checked.png\");"
				"}"
			"QCheckBox::indicator:unchecked{"
				"image: url(\":/res/unchecked.png\");"
				"}"
			
			".QWidget{"
				"background: transparent;"
				"}"

			"QTabWidget::pane {"
                "border-top-width: 2px;"
			"}"

			"QMenu{"
				"background-color: #ffcc00;"
				"margin: 3px;"
			"}"
			"QMenu::item {"
				"background-color: #0d0544;"
				"border: 1px solid transparent;"
				"font: bold;"
				"padding: 2px 25px 2px 20px;"
			"}"
			"QMenu::item:selected {"
				"background-color: #2d2564;"
			"}"
			"QMenu::indicator {"
				"width: 16px;"
				"height: 16px;"
			"}"
			"QMenu::indicator:non-exclusive:checked{"
				"image: url(\":/res/checked.png\");"
			"}"
			"QMenu::indicator:non-exclusive:unchecked{"
				"image: url(\":/res/unchecked.png\");"
			"}"

			"QToolTip{"
				"background-color: #0d0544;"
			"}"
			
			":disabled{"
				"color: #a0a0a0;"
			"}"
            "SquareLabel, ItemNum {"
				"background-color: #000000;"
			"}"
			)
		);

	bindir->cd("bin"); // workaround over NSIS installer

	cfgdir->setPath(cfgdir->homePath());
#ifdef __APPLE__
	if (checkForDir(cfgdir->absolutePath() + "/Library/Application Support/Hedgewars"))
	{
		checkForDir(cfgdir->absolutePath() + "/Library/Application Support/Hedgewars/Demos");
		checkForDir(cfgdir->absolutePath() + "/Library/Application Support/Hedgewars/Saves");
	}
	cfgdir->cd("Library/Application Support/Hedgewars");
#else
	if (checkForDir(cfgdir->absolutePath() + "/.hedgewars"))
	{
		checkForDir(cfgdir->absolutePath() + "/.hedgewars/Demos");
		checkForDir(cfgdir->absolutePath() + "/.hedgewars/Saves");
	}
	cfgdir->cd(".hedgewars");
#endif

	datadir->cd(bindir->absolutePath());
	datadir->cd(*cDataDir);
	if(!datadir->cd("hedgewars/Data")) {
		QMessageBox::critical(0, QMessageBox::tr("Error"),
			QMessageBox::tr("Failed to open data directory:\n%1\n"
					"Please check your installation").
					arg(datadir->absolutePath()+"/hedgewars/Data"));
		return 1;
	}

	QTranslator Translator;
	Translator.load(datadir->absolutePath() + "/Locale/hedgewars_" + QLocale::system().name());
	app.installTranslator(&Translator);

	Themes = new QStringList();
	QFile themesfile(datadir->absolutePath() + "/Themes/themes.cfg");
	if (themesfile.open(QIODevice::ReadOnly)) {
		QTextStream stream(&themesfile);
		QString str;
		while (!stream.atEnd())
		{
			Themes->append(stream.readLine());
		}
		themesfile.close();
	} else {
		QMessageBox::critical(0, "Error", "Cannot access themes.cfg", "OK");
	}

	QDir tmpdir;
	tmpdir.cd(datadir->absolutePath());
	tmpdir.cd("Maps");
	tmpdir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
	mapList = new QStringList(tmpdir.entryList(QStringList("*")));

	HWForm *Form = new HWForm();
	Form->show();
	return app.exec();
}
