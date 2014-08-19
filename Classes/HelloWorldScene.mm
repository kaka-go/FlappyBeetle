#include "HelloWorldScene.h"
#include "SimpleAudioEngine.h"  
#include <math.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "GameKitHelper.h"
#endif

USING_NS_CC;
#define CLOUD_SPEED_X -0.5f
#define GRASS_SPEED_X -2.5f
#define CACTUS_SPEED_X -2.3f
#define CACTUS_BLANK 250
#define GRAVITY -0.35f
#define SPEED_UP -0.04f
#define SPEED_UP_GAP 3
#define BLANK_UP 1

float cloudSpeedX = CLOUD_SPEED_X;
float grassSpeedX = GRASS_SPEED_X;

float cactusSpeedX = CACTUS_SPEED_X;
float cactusBlank = CACTUS_BLANK;
float cactusGap = 150;
float cactusWidth = 125;
int cactusNum = 3;

float beetleSpeedY = 0.0f;
float beetleX = 160;
float beetleWhirl = 0.8f;
float beetleWhirlUp = -35.0f;
float beetleWhirlDown = 40.0f;

float gravity = GRAVITY;
float forceUp = 7.0f;

int score = 0;
int bestScore = 0;

bool notStart = true;
bool isOver = false;
bool isBest = false;

CCScene* HelloWorld::scene()
{
    CCScene *scene = CCScene::create();
    HelloWorld *layer = HelloWorld::create();

    scene->addChild(layer);
    return scene;
}

// on "init" you need to initialize your instance
bool HelloWorld::init()
{
    if ( !CCLayer::init() )
    {
        return false;
    }
    
    CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
    CCPoint origin = CCDirector::sharedDirector()->getVisibleOrigin();

	bestScore = CCUserDefault::sharedUserDefault()->getIntegerForKey("bestScore", 0);
    CocosDenshion::SimpleAudioEngine::sharedEngine()->preloadEffect("pass.wav");
	CocosDenshion::SimpleAudioEngine::sharedEngine()->preloadEffect("bang.wav");
	CocosDenshion::SimpleAudioEngine::sharedEngine()->preloadEffect("fly.wav");
	CocosDenshion::SimpleAudioEngine::sharedEngine()->preloadEffect("best.wav");

	/////////////////////////////
    CCMenu* pMenu = CCMenu::create();
    pMenu->setPosition(CCPointZero);
    this->addChild(pMenu, -2);

    CCMenuItemImage *pCloseItem = CCMenuItemImage::create(
                                        "backNormal.png",
                                        "backSelected.png",
                                        this,
                                        menu_selector(HelloWorld::menuCloseCallback));
	pCloseItem->setPosition(ccp(origin.x + pCloseItem->getContentSize().width/2 ,
                                origin.y + visibleSize.height - pCloseItem->getContentSize().height/2));
    // !
    // pMenu->addChild(pCloseItem);
    
    CCMenuItemImage *pLeaderBoardItem = CCMenuItemImage::create(
                                                          "cupNormal.png",
                                                          "cupSelected.png",
                                                          this,
                                                          menu_selector(HelloWorld::leaderBoardCallback));
	pLeaderBoardItem->setPosition(ccp(origin.x + visibleSize.width - pLeaderBoardItem->getContentSize().width/2 ,
                                      origin.y + visibleSize.height - pLeaderBoardItem->getContentSize().height/2));
    pMenu->addChild(pLeaderBoardItem);


	CCMenuItemImage *pReplayItem = CCMenuItemImage::create(
                                        "replayNormal.png",
                                        "replaySelected.png",
                                        this,
                                        menu_selector(HelloWorld::menuReplayCallback));
    pReplayItem->setPosition(ccp(origin.x + pReplayItem->getContentSize().width/2 ,
								 origin.y + visibleSize.height - pReplayItem->getContentSize().height/2));

//	pReplayItem->setPosition(ccp(origin.x + visibleSize.width - pReplayItem->getContentSize().width/2 ,
//								 origin.y + visibleSize.height - pReplayItem->getContentSize().height/2));
	pMenu->addChild(pReplayItem);


    /////////////////////////////

	scoreLabel = CCLabelTTF::create("0", "Verdana", 50);
	scoreLabel->enableStroke(ccc3(0,0,0), 2, true);
	
	//scoreLabel = textAddOutlineAndShadow("0", "Verdana", 50, ccWHITE, 1, 4, 200);
    scoreLabel->setPosition(ccp(origin.x + visibleSize.width/2, origin.y + visibleSize.height - 60));
    this->addChild(scoreLabel, 1);

	bestScoreLabel = CCLabelTTF::create("Best: ", "Verdana", 30);
	bestScoreLabel->setColor(ccc3(0,0,0));
	bestScoreLabel->setAnchorPoint(ccp(0.5, 1.0));
	updateBestScore(bestScore);
	bestScoreLabel->setPosition(ccp(origin.x + visibleSize.width/2, origin.y + visibleSize.height));
    this->addChild(bestScoreLabel, -1);

	finger = CCSprite::create("finger.png");
    finger->setPosition(ccp(visibleSize.width/2 + origin.x, visibleSize.height/2 - 100 + origin.y));
    this->addChild(finger, -1);

	CCAnimation *fingerAnime = CCAnimation::create();
	fingerAnime->addSpriteFrameWithFileName("finger0.png"); 
	fingerAnime->addSpriteFrameWithFileName("finger1.png");
	fingerAnime->setDelayPerUnit(1.0f / 2);
	fingerAnime->setRestoreOriginalFrame(true);
	fingerAnime->setLoops(-1);
	CCAction *fingerAction = CCAnimate::create(fingerAnime);
	finger->runAction(fingerAction);


	sky = CCSprite::create("sky.png");
    sky->setPosition(ccp(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));
    this->addChild(sky, -10);
    
	cloud = CCSprite::create("cloud.png");
	cloud->setAnchorPoint(ccp(0, 0));
	cloud->setPosition(ccp(origin.x, origin.y + visibleSize.height/2));
	this->addChild(cloud, -9);

	grass = CCSprite::create("grass.png");
	grass->setAnchorPoint(ccp(0,0));
	grass->setPosition(ccp(origin.x, origin.y - 5));
	this->addChild(grass, -5);

	
	beetle = CCSprite::create("beetle1.png");
	beetle->setPosition(ccp(origin.x + beetleX, origin.y + visibleSize.height/2));
	this->addChild(beetle, -6);
	
	beetlePoly[0] = ccp(3, 11);
	beetlePoly[1] = ccp(7, 36);
	beetlePoly[2] = ccp(16, 53);
	beetlePoly[3] = ccp(31, 61);
	beetlePoly[4] = ccp(55, 61);
	beetlePoly[5] = ccp(72, 52);
	beetlePoly[6] = ccp(84, 36);
	beetlePoly[7] = ccp(89, 11);

	CCAnimation *animation = CCAnimation::create();
	animation->addSpriteFrameWithFileName("beetle0.png"); 
	animation->addSpriteFrameWithFileName("beetle1.png");
	animation->addSpriteFrameWithFileName("beetle2.png");
	animation->addSpriteFrameWithFileName("beetle2.png"); 
	animation->addSpriteFrameWithFileName("beetle2.png"); 
	animation->addSpriteFrameWithFileName("beetle2.png");
	animation->addSpriteFrameWithFileName("beetle2.png");
	animation->addSpriteFrameWithFileName("beetle2.png"); 
	animation->addSpriteFrameWithFileName("beetle2.png");
	animation->addSpriteFrameWithFileName("beetle1.png");
	animation->setDelayPerUnit(2.0f / 10);
	animation->setRestoreOriginalFrame(true);
	animation->setLoops(-1);
	CCAnimate *action = CCAnimate::create(animation);
	beetle->runAction(action);
		
	for(int i=0; i<cactusNum; i++){
		scored[i] = false;

		float cactusY = 300 + 300 *CCRANDOM_0_1();
		float cactusX = visibleSize.width + cactusBlank*i + cactusWidth;
		cactusDown[i] = CCSprite::create("cactusDown.png");
		cactusDown[i]->setAnchorPoint(ccp(0.5, 1));
		cactusDown[i]->setPosition(ccp(origin.x + cactusX, origin.y + cactusY));
		this->addChild(cactusDown[i], -7);

		cactusUp[i] = CCSprite::create("cactusUp.png");
		cactusUp[i]->setAnchorPoint(ccp(0.5, 0));
		cactusUp[i]->setPosition(ccp(origin.x + cactusX, origin.y + cactusY + cactusGap));
		this->addChild(cactusUp[i], -7);
	}

	cactusDownPoly[0] = ccp(7, 0);
	cactusDownPoly[1] = ccp(13, 560);
	cactusDownPoly[2] = ccp(34, 570);
	cactusDownPoly[3] = ccp(46, 589);
	cactusDownPoly[4] = ccp(75, 593);
	cactusDownPoly[5] = ccp(104, 558);
	cactusDownPoly[6] = ccp(108, 0);

	cactusUpPoly[0] = ccp(5, 450);
	cactusUpPoly[1] = ccp(17, 44);
	cactusUpPoly[2] = ccp(41, 14);
	cactusUpPoly[3] = ccp(72, 16);
	cactusUpPoly[4] = ccp(82, 32);
	cactusUpPoly[5] = ccp(106, 45);
	cactusUpPoly[6] = ccp(108, 450);

	this->schedule(schedule_selector(HelloWorld::gameLogic));
	this->setTouchEnabled(true);

	// CCDirector::sharedDirector()->pause();
    return true;
}


void HelloWorld::menuCloseCallback(CCObject* pSender)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT) || (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
	CCMessageBox("You pressed the close button. Windows Store Apps do not implement a close button.","Alert");
#else
    CCDirector::sharedDirector()->end();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
#endif
}

void HelloWorld::menuReplayCallback(CCObject* pSender)
{	
	this->setTouchEnabled(true);
	finger->setVisible(true);
	notStart = true;

	gameReset();
}

void HelloWorld::leaderBoardCallback(CCObject* pSender)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    [[GameKitHelper sharedGameKitHelper] showLeaderboard];
#else
    //other platform
#endif
}

void HelloWorld::gameReset(){
	isOver = false;
	isBest = false;

	score = 0;
	updateScore(score);
	CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
    CCPoint origin = CCDirector::sharedDirector()->getVisibleOrigin();

	grassSpeedX = GRASS_SPEED_X;
	cactusSpeedX = CACTUS_SPEED_X;
	cactusBlank = CACTUS_BLANK;

	beetle->setPositionY(origin.y + visibleSize.height/2);
	beetle->setRotation(0);
	for(int i=0; i<cactusNum; i++){
		scored[i] = false;
		float cactusY = 300 + 300 *CCRANDOM_0_1();
		float cactusX = visibleSize.width + cactusBlank*i + cactusWidth;
		cactusDown[i]->setPosition(ccp(origin.x + cactusX, origin.y + cactusY));
		cactusUp[i]->setPosition(ccp(origin.x + cactusX, origin.y + cactusY + cactusGap));
	}
}

void HelloWorld::gameOver()
{
	if(!isOver){
		if(score > bestScore) {
			bestScore = score;
            [[GameKitHelper sharedGameKitHelper] reportScore:bestScore forCategory: @"BF_BS"];
        }
		updateBestScore(bestScore);
		CCUserDefault::sharedUserDefault()->setIntegerForKey("bestScore", bestScore);
		CCUserDefault::sharedUserDefault()->flush();
	}
	isOver = true;
	CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect("bang.wav"); 
	this->setTouchEnabled(false);
}

void HelloWorld::gameLogic(float dt)
{
	if(notStart) return;

	float beetleY = beetle->getPositionY();
	beetleSpeedY += gravity;
	beetleY += beetleSpeedY;
	if(beetleY < 0) beetleY = 0;
	if(beetleY > 800) beetleY = 800;
	beetle->setPositionY(beetleY);

	float beetleAngle = beetle->getRotation();
	beetleAngle += beetleWhirl;
	if(beetleAngle > beetleWhirlDown) beetleAngle = beetleWhirlDown;
	beetle->setRotation(beetleAngle);

	if(isOver) return;

	float cloudX = cloud->getPositionX();
	cloudX += cloudSpeedX;
	if(cloudX < -960) cloudX = 0;
	cloud->setPositionX(cloudX);

	float grassX = grass->getPositionX();
	grassX += grassSpeedX;
	grassSpeedX = GRASS_SPEED_X + (score/SPEED_UP_GAP) * SPEED_UP;
	if(grassX < -1300) grassX = 0;
	grass->setPositionX(grassX);


	for(int i=0; i<cactusNum; i++){
		float cactusX = cactusDown[i]->getPositionX();
		cactusX += cactusSpeedX;
		cactusSpeedX = CACTUS_SPEED_X + (score/SPEED_UP_GAP) * SPEED_UP;
		cactusBlank = CACTUS_BLANK + (score/SPEED_UP_GAP) * BLANK_UP;

		if(cactusX < beetleX && scored[i] == false){
			CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect("pass.wav");  
			score ++;
			updateScore(score);
			scored[i] = true;
		}

		if(cactusX < -cactusWidth/2) {
			scored[i] = false;
			cactusX = -cactusWidth/2 + cactusBlank * 3;
			
			float cactusY = 300 + 300 *CCRANDOM_0_1();
			cactusDown[i]->setPositionY(cactusY);
			cactusUp[i]->setPositionY(cactusY + cactusGap);
		}

		cactusDown[i]->setPositionX(cactusX);
		cactusUp[i]->setPositionX(cactusX);
	}

	// Collision detection
	CCPoint beetleVertices[BEETLE_POLY_NUM];
	for(int i=0; i<BEETLE_POLY_NUM; i++){
		beetleVertices[i] = beetle->convertToWorldSpace(beetlePoly[i]);
	}

	CCPoint cactusDownVertices[CACTUS_POLY_NUM];
	CCPoint cactusUpVertices[CACTUS_POLY_NUM];
	for(int j=0; j<cactusNum; j++){
		for(int i=0; i<CACTUS_POLY_NUM; i++){
			cactusDownVertices[i] = cactusDown[j]->convertToWorldSpace(cactusDownPoly[i]);
			cactusUpVertices[i] = cactusUp[j]->convertToWorldSpace(cactusUpPoly[i]);
		}

		if(intersectsPoly(beetleVertices, BEETLE_POLY_NUM, cactusDownVertices, CACTUS_POLY_NUM)
			|| intersectsPoly(beetleVertices, BEETLE_POLY_NUM, cactusUpVertices, CACTUS_POLY_NUM)){
			gameOver();
		}
	}

	if( score > bestScore && ! isBest){
		CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect("best.wav");
		isBest = true;
	}
}


void HelloWorld::ccTouchesBegan(CCSet *pTouches, CCEvent *pEvent)
{
	if(notStart){
		finger->setVisible(false);
		notStart = false;
	}
	CocosDenshion::SimpleAudioEngine::sharedEngine()->playEffect("fly.wav");
	CCSetIterator iter = pTouches->begin();
	for (; iter != pTouches->end(); iter++)
	{
		CCTouch* pTouch = (CCTouch*)(*iter);
		CCPoint pos = pTouch->getLocationInView();
		pos = CCDirector::sharedDirector()->convertToGL(pos);

		beetleSpeedY = forceUp;
		beetle->setRotation(beetleWhirlUp);
	}
}

void HelloWorld::updateScore(int score)
{
	char scoreStr[100];
	sprintf(scoreStr, "%d", score);
	scoreLabel->setString(scoreStr);
}

void HelloWorld::updateBestScore(int bestScore)
{
	char scoreStr[100];
	sprintf(scoreStr, "Best: %d", bestScore);
	bestScoreLabel->setString(scoreStr);
}

void HelloWorld::draw()
{
	return;

	ccDrawColor4F(1.0f, 0.0f, 0.0f, 1.0f);
	CCRect beetleBox = beetle->boundingBox();
	//cocos2d::ccDrawRect(ccp(beetleBox.getMinX(), beetleBox.getMinY()), ccp(beetleBox.getMaxX(), beetleBox.getMaxY()));

	CCPoint beetleVertices[BEETLE_POLY_NUM];
	for(int i=0; i<BEETLE_POLY_NUM; i++){
		beetleVertices[i] = beetle->convertToWorldSpace(beetlePoly[i]);
	}
	cocos2d::ccDrawPoly(beetleVertices, BEETLE_POLY_NUM, true);

	CCPoint cactusVertices[CACTUS_POLY_NUM];
	for(int j=0; j<cactusNum; j++){
		for(int i=0; i<CACTUS_POLY_NUM; i++){
			cactusVertices[i] = cactusDown[j]->convertToWorldSpace(cactusDownPoly[i]);
		}
		cocos2d::ccDrawPoly(cactusVertices, CACTUS_POLY_NUM, true);

		for(int i=0; i<CACTUS_POLY_NUM; i++){
			cactusVertices[i] = cactusUp[j]->convertToWorldSpace(cactusUpPoly[i]);
		}
		cocos2d::ccDrawPoly(cactusVertices, CACTUS_POLY_NUM, true);
	}

	ccDrawColor4F(0.0f, 0.0f, 0.0f, 1.0f);
}

bool HelloWorld::intersectsPoly(CCPoint* poly1, int poly1Num, CCPoint* poly2, int poly2Num)
{
	for(int i=0; i<poly1Num; i++){
		for(int j=0; j<poly2Num; j++){
			if(cocos2d::ccpSegmentIntersect(poly1[i], poly1[(i+1)%poly1Num], poly2[j], poly2[(j+1)%poly2Num])){
				CCLog("%d->%d (%f, %f)->(%f, %f) ~~ %d->%d (%f, %f)->(%f, %f)", 
					i, i+1, poly1[i].x, poly1[i].y, poly1[(i+1)%poly1Num].x, poly1[(i+1)%poly1Num].y,
					j, j+1, poly2[j].x, poly2[j].y, poly1[(j+1)%poly2Num].x, poly2[(j+1)%poly2Num].y);
				return true;
			}
		}
	}
	return false;
}
/*
 制作文字描边效果是很简单的，我们写好一段文字之后，也就是创建出一个CCLabelTTF，称之为正文CCLabelTTF。然后再创建出4个CCLabelTTF，颜色为黑色，大小同正文CCLabelTTF相同，
 称之为描边CCLabelTTF。说到这大家可能已经明白了，没错，就是把4个描边CCLabelTTF放于正文CCLabelTTF的下面，分别于左右上下与正文CCLabelTTF错开，这样描边效果就实现啦。。
 
 *string     文本
 *fontName   文本字体类型
 *fontSize   文本大小
 *color3     文本颜色
 *lineWidth  所描边的宽度
 */
CCLabelTTF* HelloWorld::textAddOutline(const char* string, const char* fontName, float fontSize,const ccColor3B &color3,float lineWidth)
{
    //描边CCLabelTTF 左
    CCLabelTTF* left = CCLabelTTF::create(string, fontName, fontSize);
    left->setColor(ccBLACK);
    
    //描边CCLabelTTF 右
    CCLabelTTF* right = CCLabelTTF::create(string, fontName, fontSize);
    right->setColor(ccBLACK);
    right->setPosition(ccp(left->getContentSize().width*0.5+lineWidth*2,left->getContentSize().height*0.5));
    left->addChild(right);
    
    //描边CCLabelTTF 上
    CCLabelTTF* up = CCLabelTTF::create(string, fontName, fontSize);
    up->setColor(ccBLACK);
    up->setPosition(ccp(left->getContentSize().width*0.5+lineWidth, left->getContentSize().height*0.5+lineWidth));
    left->addChild(up);
    
    //描边CCLabelTTF 下
    CCLabelTTF* down = CCLabelTTF::create(string, fontName, fontSize);
    down->setColor(ccBLACK);
    down->setPosition(ccp(left->getContentSize().width*0.5+lineWidth, left->getContentSize().height*0.5-lineWidth));
    left->addChild(down);
    
    //正文CCLabelTTF
    CCLabelTTF* center = CCLabelTTF::create(string, fontName, fontSize);
    center->setColor(color3);
    center->setPosition(ccp(left->getContentSize().width*0.5+lineWidth, left->getContentSize().height*0.5));
    left->addChild(center);
    
    return left;
}


/*
 给文字添加阴影，一看就懂的。。。
 *string         文本
 *fontName       文本字体类型
 *fontSize       文本大小
 *color3         文本颜色
 *shadowSize     阴影大小
 *shadowOpacity  阴影透明度
 
 */
CCLabelTTF* HelloWorld::textAddShadow(const char* string, const char* fontName, float fontSize,const ccColor3B &color3,float shadowSize,float shadowOpacity)
{
    CCLabelTTF* shadow = CCLabelTTF::create(string, fontName, fontSize);
    shadow->setColor(ccBLACK);
    shadow->setOpacity(shadowOpacity);
    
    CCLabelTTF* center = CCLabelTTF::create(string, fontName, fontSize);
    center->setColor(color3);
    center->setPosition(ccp(shadow->getContentSize().width*0.5-shadowSize, shadow->getContentSize().height*0.5+shadowSize));
    shadow->addChild(center);
    
    return shadow;
}


//既添加描边又添加阴影
CCLabelTTF* HelloWorld::textAddOutlineAndShadow(const char* string, const char* fontName, float fontSize,const ccColor3B &color3,float lineWidth,float shadowSize,float shadowOpacity)
{
    CCLabelTTF* shadow = CCLabelTTF::create(string, fontName, fontSize);
    shadow->setColor(ccBLACK);
    shadow->setOpacity(shadowOpacity);
    
    CCLabelTTF* left = CCLabelTTF::create(string, fontName, fontSize);
    left->setColor(ccBLACK);
    left->setPosition(ccp(shadow->getContentSize().width*0.5-shadowSize, shadow->getContentSize().height*0.5+shadowSize));
    shadow->addChild(left);
    
    CCLabelTTF* right = CCLabelTTF::create(string, fontName, fontSize);
    right->setColor(ccBLACK);
    right->setPosition(ccp(left->getContentSize().width*0.5+lineWidth*2,left->getContentSize().height*0.5));
    left->addChild(right);
    
    CCLabelTTF* up = CCLabelTTF::create(string, fontName, fontSize);
    up->setColor(ccBLACK);
    up->setPosition(ccp(left->getContentSize().width*0.5+lineWidth, left->getContentSize().height*0.5+lineWidth));
    left->addChild(up);
    
    CCLabelTTF* down = CCLabelTTF::create(string, fontName, fontSize);
    down->setColor(ccBLACK);
    down->setPosition(ccp(left->getContentSize().width*0.5+lineWidth, left->getContentSize().height*0.5-lineWidth));
    left->addChild(down);
    
    CCLabelTTF* center = CCLabelTTF::create(string, fontName, fontSize);
    center->setColor(color3);
    center->setPosition(ccp(left->getContentSize().width*0.5+lineWidth, left->getContentSize().height*0.5));
    left->addChild(center);
    
    return shadow;
}