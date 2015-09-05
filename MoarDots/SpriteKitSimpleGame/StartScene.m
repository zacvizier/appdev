//
//  StartScene.m
//  SpriteKitSimpleGame
//
//  Created by Zac Vizier on 5/3/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

#import "StartScene.h"
#import "MyScene.h"

@interface StartScene ()

@property (nonatomic) SKLabelNode* playLabel;

@end


@implementation StartScene

-(id)initWithSize:(CGSize)size{
    
    if (self = [super initWithSize:size]) {
        SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"7_bg"];
        title.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        //title.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        title.zPosition = -1;
        [self addChild:title];
        
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode *button1 = [self fireButtonNode];
        [self addChild:button1];
        
        self.playLabel = [SKLabelNode labelNodeWithFontNamed:@"Superclarendon-Regular"];
        self.playLabel.text = @"Play!";
        self.playLabel.zPosition = 1000;
        self.playLabel.name = @"button1";
        self.playLabel.fontSize = 40;
        self.playLabel.fontColor = [SKColor blackColor];
        self.playLabel.position = CGPointMake(175,205);
        [self addChild:self.playLabel];

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
