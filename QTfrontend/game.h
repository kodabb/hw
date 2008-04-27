/*
 * Hedgewars, a worms-like game
 * Copyright (c) 2005-2008 Andrey Korotaev <unC0Rr@gmail.com>
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

#ifndef GAME_H
#define GAME_H

#include <QString>
#include "team.h"

#include "tcpBase.h"

class GameUIConfig;
class GameCFGWidget;
class TeamSelWidget;

enum GameState {
	gsNotStarted = 0,
	gsStarted  = 1,
	gsInterrupted = 2,
	gsFinished = 3,
	gsStopped = 4,
	gsDestroyed = 5
};


class HWGame : public TCPBase
{
	Q_OBJECT
public:
	HWGame(GameUIConfig * config, GameCFGWidget * gamecfg, QString ammo, TeamSelWidget* pTeamSelWidget = 0);
	virtual ~HWGame();
	void AddTeam(const QString & team);
	void PlayDemo(const QString & demofilename);
	void StartLocal();
	void StartQuick();
	void StartNet();
	void StartTraining();

 protected:
	virtual QStringList setArguments();
	virtual void onClientRead();
	virtual void onClientDisconnect();

signals:
	void SendNet(const QByteArray & msg);
	void GameStateChanged(GameState gameState);
	void GameStats(char type, const QString & info);
	void HaveRecord(bool isDemo, const QByteArray & record);
	void ErrorMessage(const QString &);

public slots:
	void FromNet(const QByteArray & msg);

private:
    enum GameType {
        gtLocal    = 1,
        gtQLocal   = 2,
        gtDemo     = 3,
        gtNet      = 4,
	gtTraining = 5
    };
	char msgbuf[MAXMSGCHARS];
	QString teams[5];
	QString ammostr;
	int TeamCount;
	GameUIConfig * config;
	GameCFGWidget * gamecfg;
	TeamSelWidget* m_pTeamSelWidget;
	GameType gameType;
	GameState gameState;

	void commonConfig();
	void SendConfig();
	void SendQuickConfig();
	void SendNetConfig();
	void SendTrainingConfig();
	void ParseMessage(const QByteArray & msg);
	void SetGameState(GameState state);
};

#endif
