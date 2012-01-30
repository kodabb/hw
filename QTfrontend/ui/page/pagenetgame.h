/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006-2011 Andrey Korotaev <unC0Rr@gmail.com>
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

#ifndef PAGE_NETGAME_H
#define PAGE_NETGAME_H

#include "HistoryLineEdit.h"

#include "AbstractPage.h"

class HWChatWidget;
class TeamSelWidget;
class GameCFGWidget;

class PageNetGame : public AbstractPage
{
        Q_OBJECT

    public:
        PageNetGame(QWidget* parent, QSettings * gameSettings);

        /**
         * Sets the room name to display.
         * @param roomName room name to be displayed.
         */
        void setRoomName(const QString & roomName);

        void displayError(const QString & message);
        void displayNotice(const QString & message);
        void displayWarning(const QString & message);

        QPushButton *BtnGo;
        QPushButton *BtnMaster;
        QPushButton *BtnStart;
        QPushButton *BtnUpdate;

        QAction * restrictJoins;
        QAction * restrictTeamAdds;

        HWChatWidget* pChatWidget;

        TeamSelWidget* pNetTeamsWidget;
        GameCFGWidget* pGameCFG;

    public slots:
        void setReadyStatus(bool isReady);
        void setUser(const QString & nickname);
        void onUpdateClick();
        void setMasterMode(bool isMaster);

    signals:
        void SetupClicked();
        void askForUpdateRoomName(const QString &);

    private:
        QLayout * bodyLayoutDefinition();
        QLayout * footerLayoutDefinition();
        void connectSignals();

        QSettings * m_gameSettings;

        HistoryLineEdit * leRoomName;
        QPushButton * btnSetup;
};

#endif
