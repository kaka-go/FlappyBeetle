#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#define BEETLE_POLY_NUM 8
#define CACTUS_POLY_NUM 7
USING_NS_CC;

class HelloWorld : public cocos2d::CCLayer
{
public:
    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();  

    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::CCScene* scene();
    
    // a selector callback
    void menuCloseCallback(CCObject* pSender);
	void menuReplayCallback(CCObject* pSender);
    
    // implement the "static node()" method manually
    CREATE_FUNC(HelloWorld);

	void gameReset();
	void gameOver();
	void gameLogic(float dt);

	virtual void ccTouchesBegan(CCSet *pTouches, CCEvent *pEvent);

	void updateScore(int score);
	void updateBestScore(int bestScore);

	virtual void draw();

	bool intersectsPoly(CCPoint* poly1, int poly1Num, CCPoint* poly2, int poly2Num);

private:
	CCSprite *sky;
	CCSprite *cloud;
	CCSprite *beetle;
	CCSprite *grass;
	CCSprite *cactusDown[3];
	CCSprite *cactusUp[3];
	CCSprite *finger;
	CCLabelTTF *scoreLabel;
	CCLabelTTF *bestScoreLabel;
	bool scored[3];
	CCPoint beetlePoly[BEETLE_POLY_NUM];
	CCPoint cactusDownPoly[CACTUS_POLY_NUM];
	CCPoint cactusUpPoly[CACTUS_POLY_NUM];
};

#endif // __HELLOWORLD_SCENE_H__
