/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006, 2007, 2009 Andrey Korotaev <unC0Rr@gmail.com>
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

#include <QResizeEvent>
#include <QGroupBox>
#include <QCheckBox>
#include <QGridLayout>
#include <QSpinBox>
#include <QLabel>
#include <QMessageBox>
#include <QTableView>
#include <QPushButton>

#include "gamecfgwidget.h"
#include "igbox.h"
#include "hwconsts.h"
#include "ammoSchemeModel.h"

GameCFGWidget::GameCFGWidget(QWidget* parent, bool externalControl) :
  QGroupBox(parent), mainLayout(this)
{
	mainLayout.setMargin(0);
//	mainLayout.setSizeConstraint(QLayout::SetMinimumSize);

	pMapContainer = new HWMapContainer(this);
	mainLayout.addWidget(pMapContainer, 0, 0);

	IconedGroupBox *GBoxOptions = new IconedGroupBox(this);
	GBoxOptions->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
	mainLayout.addWidget(GBoxOptions);

	QGridLayout *GBoxOptionsLayout = new QGridLayout(GBoxOptions);

	GameSchemes = new QComboBox(GBoxOptions);
	GBoxOptionsLayout->addWidget(GameSchemes, 0, 1);
	connect(GameSchemes, SIGNAL(currentIndexChanged(int)), this, SLOT(schemeChanged(int)));

	GBoxOptionsLayout->addWidget(new QLabel(QLabel::tr("Game scheme"), GBoxOptions), 0, 0);


	QPushButton * goToSchemePage = new QPushButton(GBoxOptions);
	goToSchemePage->setText(tr("Edit schemes"));
	GBoxOptionsLayout->addWidget(goToSchemePage, 1, 0, 1, 2);
	connect(goToSchemePage, SIGNAL(clicked()), this, SIGNAL(goToSchemes()));
	
	GBoxOptionsLayout->addWidget(new QLabel(QLabel::tr("Weapons"), GBoxOptions), 2, 0);

	WeaponsName = new QComboBox(GBoxOptions);
	GBoxOptionsLayout->addWidget(WeaponsName, 2, 1);
	
	connect(WeaponsName, SIGNAL(currentIndexChanged(int)), this, SLOT(ammoChanged(int)));
	
	QPushButton * goToWeaponPage = new QPushButton(GBoxOptions);
	goToWeaponPage->setText(tr("Edit weapons"));
	GBoxOptionsLayout->addWidget(goToWeaponPage, 3, 0, 1, 2);

	connect(goToWeaponPage, SIGNAL(clicked()), this, SLOT(jumpToWeapons()));

	connect(pMapContainer, SIGNAL(seedChanged(const QString &)), this, SLOT(seedChanged(const QString &)));
	connect(pMapContainer, SIGNAL(mapChanged(const QString &)), this, SLOT(mapChanged(const QString &)));
	connect(pMapContainer, SIGNAL(themeChanged(const QString &)), this, SLOT(themeChanged(const QString &)));
	connect(pMapContainer, SIGNAL(newTemplateFilter(int)), this, SLOT(templateFilterChanged(int)));
}

void GameCFGWidget::jumpToWeapons()
{
	emit goToWeapons(WeaponsName->currentText());
}

QVariant GameCFGWidget::schemeData(int column) const
{
	return GameSchemes->model()->data(GameSchemes->model()->index(GameSchemes->currentIndex(), column));
}

quint32 GameCFGWidget::getGameFlags() const
{
	quint32 result = 0;

	if (schemeData(1).toBool())
		result |= 0x01;
	if (schemeData(2).toBool())
		result |= 0x10;
	if (schemeData(3).toBool())
		result |= 0x04;
	if (schemeData(4).toBool())
		result |= 0x08;
	if (schemeData(5).toBool())
		result |= 0x20;
	if (schemeData(6).toBool())
		result |= 0x40;
	if (schemeData(7).toBool())
		result |= 0x80;
	if (schemeData(8).toBool())
		result |= 0x100;
	if (schemeData(9).toBool())
		result |= 0x200;
	if (schemeData(10).toBool())
		result |= 0x400;
	if (schemeData(11).toBool())
		result |= 0x800;

	return result;
}

quint32 GameCFGWidget::getInitHealth() const
{
	return schemeData(14).toInt();
}

QStringList GameCFGWidget::getFullConfig() const
{
	QStringList sl;
	sl.append("eseed " + pMapContainer->getCurrentSeed());
	sl.append(QString("e$gmflags %1").arg(getGameFlags()));
	sl.append(QString("e$damagepct %1").arg(schemeData(12).toInt()));
	sl.append(QString("e$turntime %1").arg(schemeData(13).toInt() * 1000));
	sl.append(QString("e$minestime %1").arg(schemeData(17).toInt() * 1000));
	sl.append(QString("e$landadds %1").arg(schemeData(18).toInt()));
	sl.append(QString("e$sd_turns %1").arg(schemeData(15).toInt()));
	sl.append(QString("e$casefreq %1").arg(schemeData(16).toInt()));
	sl.append(QString("e$template_filter %1").arg(pMapContainer->getTemplateFilter()));

	QString currentMap = pMapContainer->getCurrentMap();
	if (currentMap.size() > 0)
		sl.append("emap " + currentMap);
	sl.append("etheme " + pMapContainer->getCurrentTheme());
	return sl;
}

void GameCFGWidget::setNetAmmo(const QString& name, const QString& ammo)
{
	if (ammo.size() != cDefaultAmmoStore->size())
		QMessageBox::critical(this, tr("Error"), tr("Illegal ammo scheme"));

	int pos = WeaponsName->findText(name);
	if (pos == -1) {
		WeaponsName->addItem(name, ammo);
		WeaponsName->setCurrentIndex(WeaponsName->count() - 1);
	} else {
		WeaponsName->setItemData(pos, ammo);
		WeaponsName->setCurrentIndex(pos);
	}
}

void GameCFGWidget::fullNetConfig()
{
	ammoChanged(WeaponsName->currentIndex());
	
	seedChanged(pMapContainer->getCurrentSeed());
	templateFilterChanged(pMapContainer->getTemplateFilter());
	themeChanged(pMapContainer->getCurrentTheme());

	schemeChanged(GameSchemes->currentIndex());

	// map must be the last
	QString map = pMapContainer->getCurrentMap();
	if (map.size())
		mapChanged(map);
}

void GameCFGWidget::setParam(const QString & param, const QStringList & slValue)
{
	if (slValue.size() == 1)
	{
		QString value = slValue[0];
		if (param == "MAP") {
			pMapContainer->setMap(value);
			return;
		}
		if (param == "SEED") {
			pMapContainer->setSeed(value);
			return;
		}
		if (param == "THEME") {
			pMapContainer->setTheme(value);
			return;
		}
		if (param == "TEMPLATE") {
			pMapContainer->setTemplateFilter(value.toUInt());
			return;
		}
	}

	if (slValue.size() == 2)
	{
		if (param == "AMMO") {
			setNetAmmo(slValue[0], slValue[1]);
			return;
		}
	}
	
	qWarning("Got bad config param from net");
}

void GameCFGWidget::ammoChanged(int index)
{
	if (index >= 0)
		emit paramChanged(
			"AMMO",
			QStringList() << WeaponsName->itemText(index) << WeaponsName->itemData(index).toString()
		);
}

void GameCFGWidget::mapChanged(const QString & value)
{
	emit paramChanged("MAP", QStringList(value));
}

void GameCFGWidget::templateFilterChanged(int value)
{
	emit paramChanged("TEMPLATE", QStringList(QString::number(value)));
}

void GameCFGWidget::seedChanged(const QString & value)
{
	emit paramChanged("SEED", QStringList(value));
}

void GameCFGWidget::themeChanged(const QString & value)
{
	emit paramChanged("THEME", QStringList(value));
}

void GameCFGWidget::schemeChanged(int value)
{
	QStringList sl;

	int size = GameSchemes->model()->columnCount();
	for(int i = 0; i < size; ++i)
		sl << schemeData(i).toString();
		
	emit paramChanged("SCHEME", sl);
}

void GameCFGWidget::resendSchemeData()
{
	schemeChanged(GameSchemes->currentIndex());
}
