/*
 * Hedgewars, a free turn based strategy game
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

#include <QString>
#include <QByteArray>
#include <QUuid>

#include "game.h"
#include "hwconsts.h"
#include "gameuiconfig.h"
#include "gamecfgwidget.h"
#include "teamselect.h"
#include "KB.h"
#include "proto.h"

#include <QTextStream>

HWGame::HWGame(GameUIConfig * config, GameCFGWidget * gamecfg, QString ammo, TeamSelWidget* pTeamSelWidget) :
  TCPBase(true),
  m_pTeamSelWidget(pTeamSelWidget),
  ammostr(ammo)
{
	this->config = config;
	this->gamecfg = gamecfg;
	TeamCount = 0;
}

HWGame::~HWGame()
{
	SetGameState(gsDestroyed);
}

void HWGame::onClientDisconnect()
{
	switch (gameType) {
		case gtNet:
			emit HaveRecord(true, demo);
			break;
		default:
			if (gameState == gsInterrupted) emit HaveRecord(false, demo);
			else if (gameState == gsFinished) emit HaveRecord(true, demo);
	}
	SetGameState(gsStopped);
}

void HWGame::commonConfig()
{
	QByteArray buf;
	QString gt;
	switch (gameType) {
		case gtDemo:
			gt = "TD";
			break;
		case gtNet:
			gt = "TN";
			break;
		default:
			gt = "TL";
	}
	HWProto::addStringToBuffer(buf, gt);

	HWProto::addStringListToBuffer(buf, gamecfg->getFullConfig());

	if (m_pTeamSelWidget)
	{
		QList<HWTeam> teams = m_pTeamSelWidget->getPlayingTeams();
		for(QList<HWTeam>::iterator it = teams.begin(); it != teams.end(); ++it)
		{
			HWProto::addStringListToBuffer(buf,
				(*it).TeamGameConfig(gamecfg->getInitHealth()));
			HWProto::addStringToBuffer(buf, QString("eammstore %1").arg(ammostr));
		}
	}
	RawSendIPC(buf);
}

void HWGame::SendConfig()
{
	commonConfig();
}

void HWGame::SendQuickConfig()
{
	QByteArray teamscfg;

	HWProto::addStringToBuffer(teamscfg, "TL");
	HWProto::addStringToBuffer(teamscfg, QString("etheme %1")
			.arg((Themes->size() > 0) ? Themes->at(rand() % Themes->size()) : "steel"));
	HWProto::addStringToBuffer(teamscfg, "eseed " + QUuid::createUuid().toString());

	HWTeam team1(0);
	team1.difficulty = 0;
	team1.teamColor = *color1;
	team1.numHedgehogs = 4;
	HWProto::addStringListToBuffer(teamscfg,
			team1.TeamGameConfig(100));

	HWTeam team2(2);
	team2.difficulty = 4;
	team2.teamColor = *color2;
	team2.numHedgehogs = 4;
	HWProto::addStringListToBuffer(teamscfg,
			team2.TeamGameConfig(100));

	HWProto::addStringToBuffer(teamscfg, *cDefaultAmmoStore);
	HWProto::addStringToBuffer(teamscfg, *cDefaultAmmoStore);
	RawSendIPC(teamscfg);
}

void HWGame::SendTrainingConfig()
{
	QByteArray traincfg;
	HWProto::addStringToBuffer(traincfg, "TL");

	HWTeam team1(0);
	team1.difficulty = 0;
	team1.teamColor = *color1;
	team1.numHedgehogs = 1;
	HWProto::addStringListToBuffer(traincfg,
			team1.TeamGameConfig(100));

	QFile file(datadir->absolutePath() + "/Trainings/001_Shotgun.txt");
	if(!file.open(QFile::ReadOnly))
	{
		emit ErrorMessage(tr("Error reading training config file"));
		return;
	}
	
	QTextStream stream(&file);
	while(!stream.atEnd())
	{
		HWProto::addStringToBuffer(traincfg, "e" + stream.readLine());
	}

	RawSendIPC(traincfg);
}

void HWGame::SendNetConfig()
{
	commonConfig();
}

void HWGame::ParseMessage(const QByteArray & msg)
{
	switch(msg.at(1)) {
		case '?': {
			SendIPC("!");
			break;
		}
		case 'C': {
			switch (gameType) {
				case gtLocal: {
				 	SendConfig();
					break;
				}
				case gtQLocal: {
				 	SendQuickConfig();
					break;
				}
				case gtDemo: break;
				case gtNet: {
					SendNetConfig();
					break;
				}
				case gtTraining: {
				 	SendTrainingConfig();
					break;
				}
			}
			break;
		}
		case 'E': {
			int size = msg.size();
			emit ErrorMessage(QString().append(msg.mid(2)).left(size - 4));
			return;
		}
		case 'K': {
			ulong kb = msg.mid(2).toULong();
			if (kb==1) {
			  qWarning("%s", KBMessages[kb - 1].toLocal8Bit().constData());
			  return;
			}
			if (kb && kb <= KBmsgsCount)
			{
				emit ErrorMessage(KBMessages[kb - 1]);
			}
			return;
		}
		case '+': {
			if (gameType == gtNet)
			{
				emit SendNet(msg);
			}
			break;
		}
		case 'i': {
			int size = msg.size();
			emit GameStats(msg.at(2), QString::fromUtf8(msg.mid(3).left(size - 5)));
			break;
		}
		case 'Q': {
			SetGameState(gsInterrupted);
			break;
		}
		case 'q': {
			SetGameState(gsFinished);
			break;
		}
		default: {
			if (gameType == gtNet)
			{
				emit SendNet(msg);
			}
			demo.append(msg);
		}
	}
}

void HWGame::FromNet(const QByteArray & msg)
{
	RawSendIPC(msg);
}

void HWGame::onClientRead()
{
	quint8 msglen;
	quint32 bufsize;
	while (!readbuffer.isEmpty() && ((bufsize = readbuffer.size()) > 0) &&
			((msglen = readbuffer.data()[0]) < bufsize))
	{
		QByteArray msg = readbuffer.left(msglen + 1);
		readbuffer.remove(0, msglen + 1);
		ParseMessage(msg);
	}
}

QStringList HWGame::setArguments()
{
	QStringList arguments;
	QRect resolution = config->vid_Resolution();
	arguments << cfgdir->absolutePath();
	arguments << QString::number(resolution.width());
	arguments << QString::number(resolution.height());
	arguments << QString::number(config->bitDepth()); // bpp
	arguments << QString("%1").arg(ipc_port);
	arguments << (config->vid_Fullscreen() ? "1" : "0");
	arguments << (config->isSoundEnabled() ? "1" : "0");
	arguments << tr("en.txt");
	arguments << "128"; // sound volume
	arguments << QString::number(config->timerInterval());
	arguments << datadir->absolutePath();
	arguments << (config->isShowFPSEnabled() ? "1" : "0");
	arguments << (config->isAltDamageEnabled() ? "1" : "0");
	arguments << config->netNick().toUtf8().toBase64();
	return arguments;
}

void HWGame::AddTeam(const QString & teamname)
{
	if (TeamCount == 5) return;
	teams[TeamCount] = teamname;
	TeamCount++;
}

void HWGame::PlayDemo(const QString & demofilename)
{
	gameType = gtDemo;
	QFile demofile(demofilename);
	if (!demofile.open(QIODevice::ReadOnly))
	{
		emit ErrorMessage(tr("Cannot open demofile %1").arg(demofilename));
		return ;
	}

	// read demo
	toSendBuf = demofile.readAll();

	// run engine
	demo.clear();
	Start();
	SetGameState(gsStarted);
}

void HWGame::StartNet()
{
	gameType = gtNet;
	demo.clear();
	Start();
	SetGameState(gsStarted);
}

void HWGame::StartLocal()
{
	gameType = gtLocal;
	demo.clear();
	Start();
	SetGameState(gsStarted);
}

void HWGame::StartQuick()
{
	gameType = gtQLocal;
	demo.clear();
	Start();
	SetGameState(gsStarted);
}

void HWGame::StartTraining()
{
	gameType = gtTraining;
	demo.clear();
	Start();
	SetGameState(gsStarted);
}

void HWGame::SetGameState(GameState state)
{
	gameState = state;
	emit GameStateChanged(state);
}
