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

#include <QGridLayout>
#include <QPushButton>
#include <QAction>
#include <QMenu>
#include <QMessageBox>

#include "pagenetgame.h"
#include "gamecfgwidget.h"
#include "teamselect.h"
#include "chatwidget.h"

QLayout * PageNetGame::bodyLayoutDefinition()
{
    QGridLayout * pageLayout = new QGridLayout();
    pageLayout->setSizeConstraint(QLayout::SetMinimumSize);
    //pageLayout->setSpacing(1);
    pageLayout->setColumnStretch(0, 50);
    pageLayout->setColumnStretch(1, 50);

    // chatwidget
    pChatWidget = new HWChatWidget(this, m_gameSettings, m_sdli, true);
    pChatWidget->setShowReady(true); // show status bulbs by default
    pChatWidget->setShowFollow(false); // don't show follow in nicks' context menus
    pageLayout->addWidget(pChatWidget, 2, 0, 1, 2);
    pageLayout->setRowStretch(1, 100);
    pageLayout->setRowStretch(2, 100);

    pGameCFG = new GameCFGWidget(this);
    pageLayout->addWidget(pGameCFG, 0, 0);

    btnSetup = new QPushButton(this);
    btnSetup->setText(QPushButton::tr("Setup"));
    pageLayout->addWidget(btnSetup, 1, 0);

    pNetTeamsWidget = new TeamSelWidget(this);
    pNetTeamsWidget->setAcceptOuter(true);
    pageLayout->addWidget(pNetTeamsWidget, 0, 1, 2, 1);

    return pageLayout;
}

QLayout * PageNetGame::footerLayoutDefinition()
{
    QHBoxLayout * bottomLayout = new QHBoxLayout;

    leRoomName = new QLineEdit(this);
    leRoomName->setMaxLength(60);
    leRoomName->setMinimumWidth(200);
    leRoomName->setMaximumWidth(400);

    BtnGo = new QPushButton(this);
    BtnGo->setToolTip(QPushButton::tr("Ready"));
    BtnGo->setIcon(QIcon(":/res/lightbulb_off.png"));
    BtnGo->setIconSize(QSize(25, 34));
    BtnGo->setMinimumWidth(50);
    BtnGo->setMinimumHeight(50);


    bottomLayout->addWidget(leRoomName);
    BtnUpdate = addButton(QAction::tr("Update"), bottomLayout, 1, false);
    bottomLayout->addWidget(BtnGo);

    BtnMaster = addButton(tr("Control"), bottomLayout, 3);
    bottomLayout->insertStretch(3, 100);

    BtnStart = addButton(QAction::tr("Start"), bottomLayout, 3);

    return bottomLayout;
}

void PageNetGame::connectSignals()
{
    connect(btnSetup, SIGNAL(clicked()), this, SIGNAL(SetupClicked()));

    connect(BtnUpdate, SIGNAL(clicked()), this, SLOT(onUpdateClick()));
}

PageNetGame::PageNetGame(QWidget* parent, QSettings * gameSettings, SDLInteraction * sdli) : AbstractPage(parent)
{
    m_gameSettings = gameSettings;
    m_sdli = sdli;

    initPage();

    QMenu * menu = new QMenu(BtnMaster);

    restrictJoins = new QAction(QAction::tr("Restrict Joins"), menu);
    restrictJoins->setCheckable(true);
    restrictTeamAdds = new QAction(QAction::tr("Restrict Team Additions"), menu);
    restrictTeamAdds->setCheckable(true);
    //menu->addAction(startGame);
    menu->addAction(restrictJoins);
    menu->addAction(restrictTeamAdds);

    BtnMaster->setMenu(menu);

}

void PageNetGame::setReadyStatus(bool isReady)
{
    if(isReady)
        BtnGo->setIcon(QIcon(":/res/lightbulb_on.png"));
    else
        BtnGo->setIcon(QIcon(":/res/lightbulb_off.png"));
}

void PageNetGame::onUpdateClick()
{
    if (leRoomName->text().size())
        emit askForUpdateRoomName(leRoomName->text());
    else
        QMessageBox::critical(this,
                tr("Error"),
                tr("Please enter room name"),
                tr("OK"));
}

void PageNetGame::setMasterMode(bool isMaster)
{
    BtnMaster->setVisible(isMaster);
    BtnStart->setVisible(isMaster);
    BtnUpdate->setVisible(isMaster);
    leRoomName->setVisible(isMaster);
}
