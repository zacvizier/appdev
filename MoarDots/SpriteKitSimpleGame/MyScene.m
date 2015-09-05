//
//  MyScene.m
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/4/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "LoseScene.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

const int playerHeight=80;
const int startTime = 18;

// 1
@interface MyScene () <SKPhysicsContactDelegate>{
    UISwipeGestureRecognizer* swipeGestureLeft;
    UISwipeGestureRecognizer* swipeGestureRight;
    
    int level;
    int hp;
    int reduce;
    
    int statusX;
    int statusY;
    
    int mana;
    int manaRequired;
    
    int points;
    
    int timeRemaining;
    
    int drImg;
    int repeatCount;
    BOOL goingUp;
    NSArray *dr;
    
    NSArray *bg;
    int bgNum;
    
    BOOL pause;
}
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) int monstersDestroyed;

@property (nonatomic) CGPoint lane1;
@property (nonatomic) CGPoint lane2;
@property (nonatomic) CGPoint lane3;

@property SKSpriteNode* greenHealth;
@property SKSpriteNode* redHealth;
@property SKSpriteNode* manabarbg;
@property SKSpriteNode* manabar;

@property (nonatomic) SKLabelNode* scoreLabel;
@property (nonatomic) SKLabelNode* timeLabel;
@property (nonatomic) SKLabelNode* levelLabel;
@property (nonatomic) SKSpriteNode *bg_current;
@property (nonatomic) SKSpriteNode *bg_top;


@end



@implementation MyScene
 
-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.physicsWorld.gravity = CGVectorMake(0,0);

        
        
        //set starting hp
        hp = 1000;
        drImg = 0;
        repeatCount = 0;
        goingUp = true;

        
        //set up global vars
        level = 1;
        statusX=20;
        statusY = 20;
        mana = 0;
        manaRequired = 10;
        points = 0;
        bgNum = 2;
        timeRemaining = startTime + 3 * level;
        
        pause = false;
        
        //set default 3 lanes
        
        self.lane1 = CGPointMake(40,  self.frame.size.height);
        self.lane2 = CGPointMake(self.frame.size.width/2, self.frame.size.height);
        self.lane3 = CGPointMake(self.frame.size.width-40, self.frame.size.height);
 
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        bg = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"1_bg"],
              [SKTexture textureWithImageNamed:@"2_bg"],
              [SKTexture textureWithImageNamed:@"3_bg"],
              [SKTexture textureWithImageNamed:@"4_bg"],
              [SKTexture textureWithImageNamed:@"5_bg"],
              [SKTexture textureWithImageNamed:@"6_bg"], nil];
        
        self.bg_current = [SKSpriteNode spriteNodeWithImageNamed:@"1_bg"];
        self.bg_current.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.bg_current.size= CGSizeMake(self.frame.size.width, self.frame.size.height);
        self.bg_current.name =@"current";
        [self addChild:self.bg_current];
        
        self.bg_top = [SKSpriteNode spriteNodeWithImageNamed:@"2_bg"];
        self.bg_top.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + self.frame.size.height);
        self.bg_top.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        self.bg_top.name = @"top";
        [self addChild:self.bg_top];
        
        SKAction *currentBGAction = [SKAction moveToY:-self.frame.size.height/2 duration:5];
        SKAction *topBGAction = [SKAction moveToY:self.frame.size.height/2 duration:5];
        [self.bg_current runAction:currentBGAction];
        [self.bg_top runAction:topBGAction];
         
        /*
        SKSpriteNode *mute = [SKSpriteNode spriteNodeWithImageNamed:@"mute"];
        mute.position = CGPointMake(245, 520);
        mute.name = @"mute";
        mute.size = CGSizeMake(30, 30);
        [self addChild:mute];
        
        */
        
        SKSpriteNode *pause2 = [SKSpriteNode spriteNodeWithImageNamed:@"pause"];
        pause2.position = CGPointMake(280, 520);
        pause2.name = @"pause";
        pause2.size = CGSizeMake(30, 30);
        [self addChild:pause2];
         

        
       dr = [NSArray arrayWithObjects:
                      [SKTexture textureWithImageNamed:@"dr1"],
                      [SKTexture textureWithImageNamed:@"dr2"],
                      [SKTexture textureWithImageNamed:@"dr3"],
                      [SKTexture textureWithImageNamed:@"dr4"],
                      [SKTexture textureWithImageNamed:@"dr5"],
                      [SKTexture textureWithImageNamed:@"dr6"],
                      [SKTexture textureWithImageNamed:@"dr7"],
                      [SKTexture textureWithImageNamed:@"dr8"],nil];
        
        self.player = [SKSpriteNode spriteNodeWithTexture:dr[7]];
        //self.player.yScale = .4;
        self.player.size = CGSizeMake(50, 50);
        self.player.position = CGPointMake(self.lane2.x, playerHeight);
        self.player.name = @"player";
        self.player.zPosition = 1000;
        [self addChild:self.player];
        
        
        
      
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        SKShapeNode* timeBG = [SKShapeNode shapeNodeWithCircleOfRadius:18];
        timeBG.fillColor = [SKColor blackColor];
        timeBG.alpha = .5;
        timeBG.position = CGPointMake(self.frame.size.width/2, 27);
        [self addChild:timeBG];
        
        
        //configure healthbar
        /*
        self.redHealth = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(100, 15)];
        self.redHealth.position = CGPointMake(250, 15);
        self.redHealth.name=@"redHealth";
        [self addChild:self.redHealth];
        */
        
        self.redHealth = [SKSpriteNode spriteNodeWithImageNamed:@"healthbar_red"];
        self.redHealth.size = CGSizeMake(100, 15);
        self.redHealth.position = CGPointMake(245, 20);
        [self addChild:self.redHealth];
        
        self.greenHealth = [SKSpriteNode spriteNodeWithImageNamed:@"healthbar"];
        self.greenHealth.size = CGSizeMake(100, 15);
        self.greenHealth.position = CGPointMake(245, 20);
        [self addChild:self.greenHealth];
        
        self.manabarbg = [SKSpriteNode spriteNodeWithImageNamed:@"mana_bg"];
        self.manabarbg.size =CGSizeMake(100, 15);
        self.manabarbg.position = CGPointMake(245, 40);
        [self addChild:self.manabarbg];
        
        self.manabar = [SKSpriteNode spriteNodeWithImageNamed:@"mana1"];
        self.manabar.size =CGSizeMake(0, 15);
        self.manabar.anchorPoint = CGPointMake(0, 0);
        self.manabar.position = CGPointMake(195, 32);
        [self addChild:self.manabar];
        
        //show points
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", points];
        self.scoreLabel.fontSize = 20;
        self.scoreLabel.fontColor = [SKColor redColor];
        self.scoreLabel.position = CGPointMake(40, self.frame.size.height-60);
        [self addChild:self.scoreLabel];
        
        //show time
        self.timeLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
        self.timeLabel.text = [NSString stringWithFormat:@"%d", timeRemaining];
        self.timeLabel.fontSize = 20;
        self.timeLabel.fontColor = [SKColor greenColor];
        self.timeLabel.position = CGPointMake(self.frame.size.width/2, 20);
        [self addChild:self.timeLabel];
        
        //show level
        self.levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
        self.levelLabel.text = [NSString stringWithFormat:@"Level: %d", level];
        self.levelLabel.fontSize = 14;
        self.levelLabel.fontColor = [SKColor purpleColor];
        self.levelLabel.position = CGPointMake(self.frame.size.width/2 + 80, 34);
        [self addChild:self.levelLabel];
    }
    return self;
}

- (void) didEvaluateActions{
    
    //show points/time
    [self.scoreLabel removeFromParent];
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", points];
    [self addChild:self.scoreLabel];

    
    repeatCount ++;
    //go through dragons
    if(repeatCount > 1){
        points++;
        if(goingUp){
            drImg++;
        }
        else{
            drImg--;
        }
        repeatCount = 0;
    }
    if(drImg > 7){
        drImg = 6;
        goingUp = false;
    }
    if(drImg < 0){
        drImg = 1;
        goingUp = true;
    }

    self.player.size = CGSizeMake(50 + drImg * 5, 50 + drImg);

    
    self.player.texture = dr[drImg];
    
    
    //check backgrounds
    //find the "current" bg
    
    SKNode *getCurrent = [self childNodeWithName:@"current"];
    //if its -frame height, delete it
    if(getCurrent.position.y <= -self.frame.size.height/2+5){
        [getCurrent runAction:[SKAction removeFromParent]];
        
        //get the name of the top node and set it to "current"
        SKNode *getTop = [self childNodeWithName:@"top"];
        getTop.name = @"current";
        
        //tell the old top to go to -frame height
        SKAction *currentBGAction = [SKAction moveToY:-self.frame.size.height/2 duration:5];
        [getTop runAction:currentBGAction];
        
        //set up the node for the next top
        SKSpriteNode *nextBG = [SKSpriteNode spriteNodeWithTexture:bg[bgNum]];
        nextBG.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + self.frame.size.height);
        nextBG.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        nextBG.name = @"top";
        nextBG.zPosition = -1;
        [self addChild:nextBG];
        
        

        //tell the new top bg what to do
        SKAction *topBGAction = [SKAction moveToY:self.frame.size.height/2 duration:5];
        [nextBG runAction:topBGAction];
        
        bgNum++;
        if(bgNum > 5){
            bgNum = 0;
        }

    }
    
    
    //go through monsters. if any of them hit the user, delete them
    [self enumerateChildNodesWithName:@"monster" usingBlock:^(SKNode *node, BOOL *stop) {
        if(node.position.y - self.player.position.y < 20 && node.position.x == self.player.position.x){
            [node removeActionForKey:@"anim1"];
            node.name = @"dot";
            node.position = CGPointMake(statusX, statusY);
            if(statusX < self.frame.size.width/2 - 60){
                statusX+=20;
            }
            else{
                statusX = 20;
            }
            //SKAction* moveDown = [SKAction moveTo:CGPointMake(statusX, -20) duration:8];
            SKAction* moveDown = [SKAction resizeToWidth:0 height:0 duration:8];
            [node runAction:[SKAction sequence:@[moveDown,[SKAction removeFromParent] ]]];
            mana+=6;
            points+=500;
        }
    }];
    
    //go through healing dots. if any of them hit the user, delete them
    [self enumerateChildNodesWithName:@"healing" usingBlock:^(SKNode *node, BOOL *stop) {
        if(node.position.y - self.player.position.y < 20 && node.position.x == self.player.position.x){
        [node removeActionForKey:@"anim2"];
        [node removeFromParent];
        
        if(hp + 150 > 1000){
            hp = 1000;
        }
        else{
            hp += 150;
        }
        //redraw health bar
        [self.greenHealth removeFromParent];
        self.greenHealth.size = CGSizeMake(hp/10, 15);
        [self addChild:self.greenHealth];
            
            //delete the particles that were with it
            [self enumerateChildNodesWithName:@"heal" usingBlock:^(SKNode *node1, BOOL *stop) {
                if(node1.position.x - node.position.x  < abs(30) && node1.position.y - node.position.y  < abs(30)){
                    [node1 removeFromParent];
                    *stop = YES;
                }
            }];
        }
        
    }];
    
    
    
    /*
    //randomly decide if we should spawn a dot
    int roll = arc4random()%200 + 1;
    //if we get number 1 through level, spawn dot
    if(roll <= level+1){
        //pick a random # to base dot on
        int whichOne = arc4random()%5;
        [self addMonster:whichOne];
    }
     */
    
    
    int tmp = 35 - floor(manaRequired/5);
    int num;
    if(tmp > 20){
        num = arc4random()%tmp;
    }
    else{
        num = arc4random()%15;
    }
    if(num == 1){
        //spawn dot
        int whichOne = arc4random()%5;
        [self addMonster:whichOne];
    }
    
    //healing dot:
    int num2 = arc4random()%1000;
    if(num2 == 15){
        [self addhealingDot];
    }
    
    
    //mana stuff
    if(mana > manaRequired){
        mana = manaRequired;
    }
    float manaProgress = (float)mana/(float)manaRequired * 100;
    if(manaProgress <= 100){
        self.manabar.size = CGSizeMake(manaProgress, 15);
    }
    
    if(mana == manaRequired){
        level++;
        self.levelLabel.text = [NSString stringWithFormat:@"Level: %d", level];
        points+=timeRemaining * level*10;
        mana = 0;
        manaRequired +=7;
        timeRemaining = startTime + level;
        if(hp + 10*level > 1000){
            hp = 1000;
        }
        else{
            hp += 10*level;
        }
        //redraw health bar
        [self.greenHealth removeFromParent];
        self.greenHealth.size = CGSizeMake(hp/10, 15);
        [self addChild:self.greenHealth];
        
    }
    
    //check lose
    

   
}
 


- (void)addMonster:(int)type{
 
    // Create sprite
    SKSpriteNode * monster;
    if(type == 1){
        monster = [SKSpriteNode spriteNodeWithImageNamed:@"immolate"];
    }
    else if(type==2){
        monster = [SKSpriteNode spriteNodeWithImageNamed:@"corruption"];
    }
    else if(type==3){
        monster = [SKSpriteNode spriteNodeWithImageNamed:@"poison"];
    }
    else if(type==4){
        monster = [SKSpriteNode spriteNodeWithImageNamed:@"rake"];
    }
    else{
        monster = [SKSpriteNode spriteNodeWithImageNamed:@"frost"];
    }
    monster.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    monster.yScale = .8;
    monster.xScale = .8;
    monster.physicsBody.dynamic = YES;
    monster.name = @"monster";
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.collisionBitMask = 0;
  
    // Determine where to spawn the monster along the Y axis
    int minX = 1;
    int maxX = 3;
    int rangeX = maxX;
    int actualX = (arc4random() % rangeX) + minX;

 
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    if(actualX == 1){
        monster.position = self.lane1;
    }
    if(actualX == 2){
        monster.position = self.lane2;
    }
    if(actualX == 3){
        monster.position = self.lane3;
    }
    //monster.fillColor = [SKColor blueColor];
    [self addChild:monster];
 
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 5.0;
    int rangeDuration = maxDuration - minDuration;

    
    int actualDuration2 = (arc4random() % rangeDuration) + minDuration;
    
    float actualDuration = actualDuration2 - .04 * level;
    SKAction * actionMove;
    // Create the actions
    if(actualX == 1){
        actionMove = [SKAction moveTo:CGPointMake(self.lane1.x, -20) duration:actualDuration];
    }
    else if(actualX == 2){
        actionMove = [SKAction moveTo:CGPointMake(self.lane2.x, -20) duration:actualDuration];
    }
    else{
        actionMove = [SKAction moveTo:CGPointMake(self.lane3.x, -20) duration:actualDuration];
    }
    SKAction * actionMoveDone = [SKAction removeFromParent];

    
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]] withKey:@"anim1"];

 
}


- (void) addhealingDot{
    SKSpriteNode *healingDot = [SKSpriteNode spriteNodeWithImageNamed:@"healing"];
    healingDot.yScale = .8;
    healingDot.xScale = .8;
    healingDot.name = @"healing";
    
    // Determine where to spawn the monster along the Y axis
    int minX = 1;
    int maxX = 3;
    int rangeX = maxX;
    int actualX = (arc4random() % rangeX) + minX;
    
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    if(actualX == 1){
        healingDot.position = self.lane1;
    }
    if(actualX == 2){
        healingDot.position = self.lane2;
    }
    if(actualX == 3){
        healingDot.position = self.lane3;
    }
    [self addChild:healingDot];
    
    // Determine speed of the monster
    int minDuration = 1.0;
    int maxDuration = 3.0;
    int rangeDuration = maxDuration - minDuration;
    
    
    int actualDuration2 = (arc4random() % rangeDuration) + minDuration;
    
    float actualDuration = actualDuration2 - .04 * level;
    SKAction * actionMove;
    // Create the actions
    if(actualX == 1){
        actionMove = [SKAction moveTo:CGPointMake(self.lane1.x, -20) duration:actualDuration];
    }
    else if(actualX == 2){
        actionMove = [SKAction moveTo:CGPointMake(self.lane2.x, -20) duration:actualDuration];
    }
    else{
        actionMove = [SKAction moveTo:CGPointMake(self.lane3.x, -20) duration:actualDuration];
    }
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [healingDot runAction:[SKAction sequence:@[actionMove, actionMoveDone]] withKey:@"anim2"];
    
    
    
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"heal" ofType:@"sks"];
    SKEmitterNode *heal = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    heal.particlePosition = CGPointMake(healingDot.position.x, healingDot.position.y);
    heal.name=@"heal";
    heal.particleBirthRate = 35;
    heal.zPosition = 1;
    heal.targetNode = self.scene;
    [self addChild:heal];
    
    SKAction *actionMovePart = [SKAction moveTo:CGPointMake(0, -self.size.height) duration:actualDuration];
    SKAction *actionMoveDonePart = [SKAction removeFromParent];
    [heal runAction:[SKAction sequence:@[actionMovePart, actionMoveDonePart]]];
    
    
    
}

-(void) deleteAllMonster{
    [self enumerateChildNodesWithName:@"fire" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:[SKAction removeFromParent]];
         }];
    [self enumerateChildNodesWithName:@"heal" usingBlock:^(SKNode *node, BOOL *stop) {
        [node runAction:[SKAction removeFromParent]];
    }];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
 
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self reduceHealth];
        //change time
        if(timeRemaining != 0 && hp > 0){
            timeRemaining--;
        }
        else{
            //you lose...
            //delete all fireballs
            [self deleteAllMonster];
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene *loser = [[LoseScene alloc]initWithSize:self.size withScore:points];
            [self.view presentScene:loser transition: reveal];
        }
        
        [self.timeLabel removeFromParent];
        self.timeLabel.text = [NSString stringWithFormat:@"%d", timeRemaining];
        if(timeRemaining > 15){
            self.timeLabel.fontColor = [SKColor greenColor];
        }
        if(timeRemaining <= 15 && timeRemaining > 8){
            self.timeLabel.fontColor = [SKColor yellowColor];
        }
        if(timeRemaining <= 8){
            self.timeLabel.fontColor = [SKColor redColor];
        }
        [self addChild:self.timeLabel];
        
        
    }
    
}


-(void)reduceHealth{
    
    reduce = 0;
    [self enumerateChildNodesWithName:@"dot" usingBlock:^(SKNode *node, BOOL *stop2) {
        //how much health to reduce
        reduce += 10;
        
        /*
        if([node.name  isEqual: @"immolate"]){
            reduce += 10;
        }
        if([node.name  isEqual: @"immolate"]){
            reduce += 10;
        }
         */
    }];
    if(hp >= 0) {
        hp -= reduce;
    }
    else{
        hp = 0;
    }
    
    //animate the greenHealth
    SKAction* healthDrop = [SKAction resizeToWidth:hp/10 height:self.greenHealth.size.height duration:.1];
    [self.greenHealth runAction:[SKAction sequence:@[healthDrop]]];

}



- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
 
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
 
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if mute is touched, turn volume down
    if ([node.name isEqualToString:@"pause"]) {
        if(!pause){
            self.scene.view.paused = YES;
            pause = true;
        }
        else{
            self.scene.view.paused = NO;
            pause = false;
        }

    }
    
    else{
    [self runAction:[SKAction playSoundFileNamed:@"fireball_burst.mp3" waitForCompletion:NO]];
 
    // 1 - Choose one of the touches to work with
    //UITouch * touch = [touches anyObject];
    //CGPoint location = [touch locationInNode:self];
 
    // 2 - Set up initial location of projectile
    
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = CGPointMake(self.player.position.x, self.player.position.y+self.player.size.height/2);
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.alpha = 0;
    projectile.name = @"projectile";
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    [self addChild:projectile];

    //shoot the fireball
    SKAction * actionMove = [SKAction moveTo:CGPointMake(self.player.position.x, self.frame.size.height) duration:2];
    SKAction * actionMoveDone = [SKAction removeFromParent];
 
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"fire" ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    fire.particlePosition = CGPointMake(self.player.position.x, self.player.position.y+self.player.size.height/2);
    fire.name=@"fire";
    fire.particleBirthRate = 100;
    fire.targetNode = self.scene;
    [self addChild:fire];
    
    //shoot the fireball
    SKAction * actionMove2 = [SKAction moveTo:CGPointMake(0, self.frame.size.height-playerHeight) duration:2];
    SKAction * actionMoveDone2 = [SKAction removeFromParent];
    
    [fire runAction:[SKAction sequence:@[actionMove2, actionMoveDone2]]];
    
    mana-=1;
    if(mana < 0){
        mana = 0;
    }
    }
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    [self enumerateChildNodesWithName:@"fire" usingBlock:^(SKNode *node, BOOL *stop) {
        if(node.position.x - projectile.position.x  < abs(30) && node.position.y - projectile.position.y  < abs(30)){
            [node removeFromParent];
            *stop = YES;
        }
    }];
    [projectile removeFromParent];
    [monster removeFromParent];
    mana+=3;
    points+=100;
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    //projectile vs monster
 
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
 
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}

-(void)didMoveToView:(SKView *)view{
    swipeGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeft:)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer:swipeGestureLeft];
    
    swipeGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeRight:)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer:swipeGestureRight];
}

-(void) handleSwipeLeft:(UISwipeGestureRecognizer *) recognizer {
    SKAction* actionMove;

    
    //move to the lane to the left, assuming we're not in lane 1
    if(self.lane2.x == self.player.position.x){
        actionMove = [SKAction moveTo:CGPointMake(self.lane1.x, playerHeight) duration:.1];
    }
    if(self.lane3.x == self.player.position.x){
        actionMove = [SKAction moveTo:CGPointMake(self.lane2.x, playerHeight) duration:.1];
    }
    
    [self.player runAction:actionMove];
}

-(void) handleSwipeRight:(UISwipeGestureRecognizer *) recognizer{
    SKAction* actionMove;

    
    //move to the lane to the right, assuming we're not in lane 3
    
    if(self.lane1.x == self.player.position.x){
        actionMove = [SKAction moveTo:CGPointMake(self.lane2.x, playerHeight) duration:.1];
    }
    if(self.lane2.x == self.player.position.x){
        actionMove = [SKAction moveTo:CGPointMake(self.lane3.x, playerHeight) duration:.1];
    }
    
    [self.player runAction:actionMove];
    
}

-(void) willMoveFromView:(SKView *)view{
    [view removeGestureRecognizer:swipeGestureRight];
    [view removeGestureRecognizer:swipeGestureLeft];
}

@end




















