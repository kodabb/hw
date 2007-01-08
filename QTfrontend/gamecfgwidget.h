/*
 * Hedgewars, a worms-like game
 * Copyright (c) 2006 Andrey Korotaev <unC0Rr@gmail.com>
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

#ifndef GAMECONFIGWIDGET_H
#define GAMECONFIGWIDGET_H

#include <QWidget>

#include "mapContainer.h"

class QCheckBox;
class QVBoxLayout;
class QSpinBox;
class QLabel;

class GameCFGWidget : public QWidget
{
	Q_OBJECT

public:
	GameCFGWidget(QWidget* parent=0);
	quint32 getGameFlags();
	QString getCurrentSeed() const;
	QString getCurrentMap() const;
	QString getCurrentTheme() const;

private slots:

private:
	QCheckBox * CB_mode_Forts;
	QVBoxLayout mainLayout;
	HWMapContainer* pMapContainer;
	QSpinBox * SB_TurnTime;
	QSpinBox * SB_InitHealth;
	QLabel * L_TurnTime;
	QLabel * L_InitHealth;
};

#endif // GAMECONFIGWIDGET_H
