/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006-2012 Andrey Korotaev <unC0Rr@gmail.com>
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
#include <QStringList>
#include <QGroupBox>
#include <QSpinBox>
#include <QRegExp>

#include "mapContainer.h"

class QCheckBox;
class QVBoxLayout;
class QLabel;
class QTableView;

class GameCFGWidget : public QGroupBox
{
        Q_OBJECT

    public:
        GameCFGWidget(QWidget* parent);
        quint32 getGameFlags() const;
        quint32 getInitHealth() const;
        QByteArray getFullConfig() const;
        QComboBox * Scripts;
        QComboBox * GameSchemes;
        QComboBox * WeaponsName;
        HWMapContainer* pMapContainer;
        QTableView * tv;
        QVariant schemeData(int column) const;

    public slots:
        void setParam(const QString & param, const QStringList & value);
        void fullNetConfig();
        void resendSchemeData();

    signals:
        void paramChanged(const QString & param, const QStringList & value);
        void goToSchemes(int);
        void goToWeapons(int);
        void goToDrawMap();

    private slots:
        void ammoChanged(int index);
        void mapChanged(const QString &);
        void templateFilterChanged(int);
        void seedChanged(const QString &);
        void themeChanged(const QString &);
        void schemeChanged(int);
        void scriptChanged(int);
        void jumpToSchemes();
        void jumpToWeapons();
        void mapgenChanged(MapGenerator m);
        void maze_sizeChanged(int s);
        void onDrawnMapChanged(const QByteArray & data);

    private:
        QGridLayout mainLayout;
        QCheckBox * bindEntries;
        QString curNetAmmoName;
        QString curNetAmmo;
        QRegExp seedRegexp;

        void setNetAmmo(const QString& name, const QString& ammo);

};

#endif // GAMECONFIGWIDGET_H
