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

#include "pagesingleplayer.h"
#include "gamecfgwidget.h"

QLayout * PageSinglePlayer::bodyLayoutDefinition()
{
    QVBoxLayout * vLayout = new QVBoxLayout();

    QHBoxLayout * topLine = new QHBoxLayout();
    QHBoxLayout * middleLine = new QHBoxLayout();
    vLayout->addStretch();
    vLayout->addLayout(topLine);
    vLayout->addSpacing(30);
    vLayout->addLayout(middleLine);
    vLayout->addStretch();

    topLine->addStretch();
    BtnSimpleGamePage = addButton(":/res/SimpleGame.png", topLine, 0, true);
    BtnSimpleGamePage->setToolTip(tr("Simple Game (a quick game against the computer, settings are chosen for you)"));
    topLine->addSpacing(60);
    BtnMultiplayer = addButton(":/res/Multiplayer.png", topLine, 1, true);
    BtnMultiplayer->setToolTip(tr("Multiplayer (play a hotseat game against your friends, or AI teams)"));
    topLine->addStretch();


    BtnCampaignPage = addButton(":/res/Campaign.png", middleLine, 0, true);
    BtnCampaignPage->setToolTip(tr("Campaign Mode (...)"));
    BtnCampaignPage->setVisible(false);

    BtnTrainPage = addButton(":/res/Trainings.png", middleLine, 1, true);
    BtnTrainPage->setToolTip(tr("Training Mode (Practice your skills in a range of training missions)"));

    return vLayout;
}

QLayout * PageSinglePlayer::footerLayoutDefinition()
{
    QHBoxLayout * bottomLine = new QHBoxLayout();
    bottomLine->addStretch();

    BtnDemos = addButton(":/res/Record.png", bottomLine, 1, true);
    BtnDemos->setToolTip(tr("Demos (Watch recorded demos)"));
    BtnLoad = addButton(":/res/Load.png", bottomLine, 2, true);
    BtnLoad->setStyleSheet("QPushButton{margin: 24px 0 0 0;}");
    BtnLoad->setToolTip(tr("Load (Load a previously saved game)"));

    bottomLine->setStretch(1,0);
    bottomLine->setStretch(2,0);
    bottomLine->setAlignment(BtnDemos, Qt::AlignRight | Qt::AlignBottom);
    bottomLine->setAlignment(BtnLoad, Qt::AlignRight | Qt::AlignBottom);

    return bottomLine;
}

void PageSinglePlayer::connectSignals()
{
    //TODO
}

PageSinglePlayer::PageSinglePlayer(QWidget* parent) : AbstractPage(parent)
{
    initPage();
}
