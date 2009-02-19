/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006-2008 Igor Ulyanov <iulyanov@gmail.com>
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

#include <QPushButton>
#include <QBuffer>
#include <QUuid>
#include <QBitmap>
#include <QPainter>
#include <QLinearGradient>
#include <QColor>
#include <QTextStream>
#include <QApplication>
#include <QLabel>
#include <QListWidget>
#include <QVBoxLayout>
#include <QIcon>

#include "hwconsts.h"
#include "mapContainer.h"
#include "igbox.h"

HWMapContainer::HWMapContainer(QWidget * parent) :
	QWidget(parent),
	mainLayout(this),
	pMap(0)
{
	hhSmall.load(":/res/hh_small.png");
	hhLimit = 18;
    templateFilter = 0;
	
	mainLayout.setContentsMargins(QApplication::style()->pixelMetric(QStyle::PM_LayoutLeftMargin),
		1,
		QApplication::style()->pixelMetric(QStyle::PM_LayoutRightMargin),
		QApplication::style()->pixelMetric(QStyle::PM_LayoutBottomMargin));
	
	imageButt = new QPushButton(this);
	imageButt->setObjectName("imageButt");
	imageButt->setFixedSize(256 + 6, 128 + 6);
	imageButt->setFlat(true);
	imageButt->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);//QSizePolicy::Minimum, QSizePolicy::Minimum);
	mainLayout.addWidget(imageButt, 0, 0, 1, 2);
	connect(imageButt, SIGNAL(clicked()), this, SLOT(setRandomSeed()));
	connect(imageButt, SIGNAL(clicked()), this, SLOT(setRandomTheme()));

	chooseMap = new QComboBox(this);
	chooseMap->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
	chooseMap->addItem(QComboBox::tr("generated map..."));
	for (int i = 0; i < mapList->size(); ++i) {
		QString map = (*mapList)[i];
		QFile mapCfgFile(
				QString("%1/Maps/%2/map.cfg")
				.arg(datadir->absolutePath())
				.arg(map));

		if (mapCfgFile.open(QFile::ReadOnly)) {
			QString theme;
			quint32 limit = 0;
			QList<QVariant> mapInfo;
			QTextStream input(&mapCfgFile);
			input >> theme;
			input >> limit;
			mapInfo.push_back(theme);
			if (limit)
				mapInfo.push_back(limit);
			else
				mapInfo.push_back(18);
			chooseMap->addItem(map, mapInfo);
			mapCfgFile.close();
		}
	}
	
	connect(chooseMap, SIGNAL(currentIndexChanged(int)), this, SLOT(mapChanged(int)));
	mainLayout.addWidget(chooseMap, 1, 1);

	QLabel * lblMap = new QLabel(tr("Map"), this);
	mainLayout.addWidget(lblMap, 1, 0);

	lblFilter = new QLabel(tr("Filter"), this);
	mainLayout.addWidget(lblFilter, 2, 0);

	CB_TemplateFilter = new QComboBox(this);
    CB_TemplateFilter->addItem(tr("All"), 0);
    CB_TemplateFilter->addItem(tr("Small"), 1);
    CB_TemplateFilter->addItem(tr("Medium"), 2);
    CB_TemplateFilter->addItem(tr("Large"), 3);
    CB_TemplateFilter->addItem(tr("Cavern"), 4);
    CB_TemplateFilter->addItem(tr("Wacky"), 5);
	mainLayout.addWidget(CB_TemplateFilter, 2, 1);

	connect(CB_TemplateFilter, SIGNAL(currentIndexChanged(int)), this, SLOT(templateFilterChanged(int)));

	gbThemes = new IconedGroupBox(this);
	gbThemes->setTitleTextPadding(60);
	gbThemes->setContentTopPadding(6);
	gbThemes->setTitle(tr("Themes"));

	//gbThemes->setStyleSheet("padding: 0px"); // doesn't work - stylesheet is set with icon
	mainLayout.addWidget(gbThemes, 0, 2, 3, 1);
	
	QVBoxLayout * gbTLayout = new QVBoxLayout(gbThemes);
	gbTLayout->setContentsMargins(0, 0, 0 ,0);
	gbTLayout->setSpacing(0);
	lwThemes = new QListWidget(this);
	lwThemes->setMinimumHeight(30);
	lwThemes->setFixedWidth(120);
	for (int i = 0; i < Themes->size(); ++i) {
		QListWidgetItem * lwi = new QListWidgetItem();
		lwi->setText(Themes->at(i));
		lwi->setTextAlignment(Qt::AlignHCenter);
		lwThemes->addItem(lwi);
	}
	connect(lwThemes, SIGNAL(currentRowChanged(int)), this, SLOT(themeSelected(int)));

    // override default style to tighten up theme scroller
	lwThemes->setStyleSheet(QString(
		"QListWidget{"
			"border: solid;"
			"border-width: 0px;"
			"border-radius: 0px;"
			"border-color: transparent;"
			"background-color: #0d0544;"
			"color: #ffcc00;"
			"font: bold 14px;"
			"}"
		)
	);
 
	gbTLayout->addWidget(lwThemes);
	lwThemes->setSizePolicy(QSizePolicy::Maximum, QSizePolicy::Minimum);
	
	mainLayout.setSizeConstraint(QLayout::SetFixedSize);//SetMinimumSize

	setRandomSeed();
	setRandomTheme();
}

void HWMapContainer::setImage(const QImage newImage)
{
	QPixmap px(256, 128);
	QPixmap pxres(256, 128);
	QPainter p(&pxres);

	px.fill(Qt::yellow);
	QBitmap bm = QBitmap::fromImage(newImage);
	px.setMask(bm);

	QLinearGradient linearGrad(QPoint(128, 0), QPoint(128, 128));
	linearGrad.setColorAt(1, QColor(0, 0, 192));
	linearGrad.setColorAt(0, QColor(66, 115, 225));
	p.fillRect(QRect(0, 0, 256, 128), linearGrad);
	p.drawPixmap(QPoint(0, 0), px);

    addInfoToPreview(pxres);
	chooseMap->setCurrentIndex(0);
	pMap = 0;
}

void HWMapContainer::setHHLimit(int newHHLimit)
{
    hhLimit = newHHLimit;
}

void HWMapContainer::mapChanged(int index)
{
	if(!index) {
		changeImage();
		gbThemes->show();
        lblFilter->show();
        CB_TemplateFilter->show();
		emit mapChanged("+rnd+");
		emit themeChanged(chooseMap->itemData(0).toString());
	} else
	{
		loadMap(index);
		gbThemes->hide();
        lblFilter->hide();
        CB_TemplateFilter->hide();
		emit mapChanged(chooseMap->currentText());
	}
}

void HWMapContainer::loadMap(int index)
{
	QPixmap mapImage;
	if(!mapImage.load(datadir->absolutePath() + "/Maps/" + chooseMap->currentText() + "/preview.png")) {
		changeImage();
		chooseMap->setCurrentIndex(0);
		return;
	}

    hhLimit = chooseMap->itemData(index).toList()[1].toInt();
    addInfoToPreview(mapImage);
}

// Should this add text to identify map size?
void HWMapContainer::addInfoToPreview(QPixmap image)
{
	QPixmap finalImage = QPixmap(image.size());
	finalImage.fill(QColor(0, 0, 0, 0));
	
	QPainter p(&finalImage);
	p.drawPixmap(image.rect(), image);
	//p.setPen(QColor(0xf4,0x9e,0xe9));
	p.setPen(QColor(0xff,0xcc,0x00));
	p.setBrush(QColor(0, 0, 0));
	p.drawRect(image.rect().width() - hhSmall.rect().width() - 28, 3, 40, 20);
	p.setFont(QFont("MS Shell Dlg", 10));
	p.drawText(image.rect().width() - hhSmall.rect().width() - 14 - (hhLimit > 9 ? 10 : 0), 18, QString::number(hhLimit));
	p.drawPixmap(image.rect().width() - hhSmall.rect().width() - 5, 5, hhSmall.rect().width(), hhSmall.rect().height(), hhSmall);

	imageButt->setIcon(finalImage);
	imageButt->setIconSize(image.size());
}

void HWMapContainer::changeImage()
{
	pMap = new HWMap();
	connect(pMap, SIGNAL(ImageReceived(const QImage)), this, SLOT(setImage(const QImage)));
	connect(pMap, SIGNAL(HHLimitReceived(int)), this, SLOT(setHHLimit(int)));
	pMap->getImage(m_seed.toStdString(), getTemplateFilter());
}

void HWMapContainer::themeSelected(int currentRow)
{
	QString theme = Themes->at(currentRow);
    QList<QVariant> mapInfo;
    mapInfo.push_back(theme);
    mapInfo.push_back(18);
	chooseMap->setItemData(0, mapInfo);
	gbThemes->setIcon(QIcon(QString("%1/Themes/%2/icon.png").arg(datadir->absolutePath()).arg(theme)));
	emit themeChanged(theme);
}

QString HWMapContainer::getCurrentSeed() const
{
  return m_seed;
}

QString HWMapContainer::getCurrentMap() const
{
  if(!chooseMap->currentIndex()) return QString();
  return chooseMap->currentText();
}

QString HWMapContainer::getCurrentTheme() const
{
	return chooseMap->itemData(chooseMap->currentIndex()).toList()[0].toString();
}

int HWMapContainer::getCurrentHHLimit() const
{
	return hhLimit;
}

quint32 HWMapContainer::getTemplateFilter() const
{
	return CB_TemplateFilter->itemData(CB_TemplateFilter->currentIndex()).toInt();
}

void HWMapContainer::resizeEvent ( QResizeEvent * event )
{
  //imageButt->setIconSize(imageButt->size());
}

void HWMapContainer::setSeed(const QString & seed)
{
	m_seed = seed;
	changeImage();
}

void HWMapContainer::setMap(const QString & map)
{
	if(map == "+rnd+")
	{
		changeImage();
		return;
	}
	
	int id = chooseMap->findText(map);
	if(id > 0) {
		chooseMap->setCurrentIndex(id);
		loadMap(id);
		if (pMap)
		{
			disconnect(pMap, 0, this, SLOT(setImage(const QImage)));
			pMap = 0;
		}
	}
}

void HWMapContainer::setTheme(const QString & theme)
{
	QList<QListWidgetItem *> items = lwThemes->findItems(theme, Qt::MatchExactly);
	if(items.size())
		lwThemes->setCurrentItem(items.at(0));
}

void HWMapContainer::setRandomSeed()
{
  m_seed = QUuid::createUuid().toString();
  emit seedChanged(m_seed);
  changeImage();
}

void HWMapContainer::setRandomTheme()
{
	if(!Themes->size()) return;
	quint32 themeNum = rand() % Themes->size();
	lwThemes->setCurrentRow(themeNum);
}

void HWMapContainer::setTemplateFilter(int filter)
{
	CB_TemplateFilter->setCurrentIndex(filter);
}

void HWMapContainer::templateFilterChanged(int filter)
{
    changeImage();
	emit newTemplateFilter(filter);
}

