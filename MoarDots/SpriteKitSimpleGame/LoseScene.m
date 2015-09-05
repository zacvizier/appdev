//
//  LoseScene.m
//  SpriteKitSimpleGame
//
//  Created by Zac Vizier on 5/4/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "LoseScene.h"
#import "MyScene.h"

@interface LoseScene ()

@property (nonatomic) SKLabelNode* playLabel;
@property (nonatomic) SKLabelNode* playLabel2;
@property (nonatomic) SKLabelNode* scoreLabel;

@end


@implementation LoseScene

-(id)initWithSize:(CGSize)size withScore:(int)score{
    
    if (self = [super initWithSize:size]) {
        
        
        
        SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"7_bg"];
        title.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        title.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        title.zPosition = -1;
        [self addChild:title];
        
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode *button1 = [self fireButtonNode];
        [self addChild:button1];
        
        self.playLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
        self.playLabel.text = @"Play Again!";
        self.playLabel.zPosition = 1000;
        self.playLabel.name = @"button1";
        self.playLabel.fontSize = 20;
        self.playLabel.fontColor = [SKColor blackColor];
        self.playLabel.position = CGPointMake(175,215);
        [self addChild:self.playLabel];
        
        
        self.playLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
        self.playLabel2.text = @"You Lost";
        self.playLabel2.zPosition = 1000;
        self.playLabel2.fontSize = 40;
        self.playLabel2.fontColor = [SKColor blackColor];
        self.playLabel2.position = CGPointMake(self.frame.size.width/2,265);
        [self addChild:self.playLabel2];
        
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
        self.scoreLabel.text = [NSString stringWithFormat:@"Your score was: %d", score];
        self.scoreLabel.zPosition = 1000;
        self.scoreLabel.name = @"button1";
        self.scoreLabel.fontSize = 20;
        self.scoreLabel.fontColor = [SKColor blackColor];
        self.scoreLabel.position = CGPointMake(160,150);
        [self addChild:self.scoreLabel];
        
        
        
    }
    return self;
}

//fire button
- (SKSpriteNode *)fireButtonNode
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"healthbar_red"];
    fireNode.position = CGPointMake(175,220);
    fireNode.size = CGSizeMake(180, 80);
    fireNode.name = @"button1";//how the node is identified later
    fireNode.zPosition = 1.0;
    return fireNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if button is touched, open up next scene
    if ([node.name isEqualToString:@"button1"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * playScene = [[MyScene alloc] initWithSize:self.size];
        [self.view presentScene:playScene transition: reveal];
    }
}

@end
