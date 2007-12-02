/*
 * Hedgewars, a worms-like game
 * Copyright (c) 2006, 2007 Andrey Korotaev <unC0Rr@gmail.com>
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

#include <QFont>
#include <QGridLayout>
#include <QPushButton>
#include <QListWidget>
#include <QListWidgetItem>
#include <QFileInfo>
#include <QMessageBox>
#include <QInputDialog>

#include "hwconsts.h"
#include "playrecordpage.h"

PagePlayDemo::PagePlayDemo(QWidget* parent) : QWidget(parent)
{
	QFont * font14 = new QFont("MS Shell Dlg", 14);
	QGridLayout * pageLayout = new QGridLayout(this);
	pageLayout->setColumnStretch(0, 1);
	pageLayout->setColumnStretch(1, 2);
	pageLayout->setColumnStretch(2, 1);

	BtnBack = new QPushButton(this);
	BtnBack->setFont(*font14);
	BtnBack->setText(QPushButton::tr("Back"));
	pageLayout->addWidget(BtnBack, 2, 0);

	BtnPlayDemo = new QPushButton(this);
	BtnPlayDemo->setFont(*font14);
	BtnPlayDemo->setText(QPushButton::tr("Play demo"));
	pageLayout->addWidget(BtnPlayDemo, 2, 2);

	BtnRenameRecord = new QPushButton(this);
//	BtnRenameRecord->setFont(*font14);
	BtnRenameRecord->setText(QPushButton::tr("Rename"));
	pageLayout->addWidget(BtnRenameRecord, 0, 2);

	DemosList = new QListWidget(this);
	DemosList->setGeometry(QRect(170, 10, 311, 311));
	pageLayout->addWidget(DemosList, 0, 1, 2, 1);

	connect(BtnRenameRecord, SIGNAL(clicked()), this, SLOT(renameRecord()));
}

void PagePlayDemo::FillFromDir(RecordType rectype)
{
	QDir dir;
	QString extension;

	recType = rectype;

	dir.cd(cfgdir->absolutePath());
	if (rectype == RT_Demo)
	{
		dir.cd("Demos");
		extension = "hwd_" + *cProtoVer;
		BtnPlayDemo->setText(QPushButton::tr("Play demo"));
	} else
	{
		dir.cd("Saves");
		extension = "hws_" + *cProtoVer;
		BtnPlayDemo->setText(QPushButton::tr("Load"));
	}
	dir.setFilter(QDir::Files);

	QStringList sl = dir.entryList(QStringList(QString("*.%1").arg(extension)));
	sl.replaceInStrings(QRegExp(QString("^(.*)\\.%1$").arg(extension)), "\\1");

	DemosList->clear();
	DemosList->addItems(sl);

	for (int i = 0; i < DemosList->count(); ++i)
	{
		DemosList->item(i)->setData(Qt::UserRole, dir.absoluteFilePath(QString("%1.%2").arg(sl[i], extension)));
	}
}

void PagePlayDemo::renameRecord()
{
	QListWidgetItem * curritem = DemosList->currentItem();
	if (!curritem)
	{
		QMessageBox::critical(this,
				tr("Error"),
				tr("Please, select record from the list"),
				tr("OK"));
		return ;
	}
	QFile rfile(curritem->data(Qt::UserRole).toString());

	QFileInfo finfo(rfile);

	bool ok;

	QString newname = QInputDialog::getText(this, tr("Rename dialog"), tr("Enter new file name:"), QLineEdit::Normal, finfo.completeBaseName(), &ok);

	if(ok && newname.size())
	{
		QString newfullname = QString("%1/%2.%3")
		                              .arg(finfo.absolutePath())
		                              .arg(newname)
		                              .arg(finfo.suffix());

		ok = rfile.rename(newfullname);
		if(!ok)
			QMessageBox::critical(this, tr("Error"), tr("Cannot rename to") + newfullname);
		else
			FillFromDir(recType);
	}
}
