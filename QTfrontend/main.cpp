/*
 * Hedgewars, a worms-like game
 * Copyright (c) 2005, 2006 Andrey Korotaev <unC0Rr@gmail.com>
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
#include <QFileInfo>
#include <QDateTime>
#include "hwform.h"
#include "hwconsts.h"

QDir * bindir;
QDir * cfgdir;
QDir * datadir;

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

	QDateTime now = QDateTime::currentDateTime();
	QDateTime zero;
	srand(now.secsTo(zero));

	Q_INIT_RESOURCE(hedgewars);

	QTranslator Translator;
	Translator.load(":/translations/hedgewars_" + QLocale::system().name());
	app.installTranslator(&Translator);

	QDir mydir(".");
	mydir.cd("bin");

	bindir = new QDir(mydir);
	cfgdir = new QDir();

	cfgdir->setPath(cfgdir->homePath());
	if (checkForDir(cfgdir->absolutePath() + "/.hedgewars"))
	{
		checkForDir(cfgdir->absolutePath() + "/.hedgewars/Demos");
	}
	cfgdir->cd(".hedgewars");

	datadir = new QDir("../share/");
	datadir->cd("hedgewars/Data");

	HWForm *Form = new HWForm();
	Form->show();
	return app.exec();
}
