//
//  eazesportzUploadHighlightWindowController.m
//  EazesportzHighlights
//
//  Created by Gil on 3/8/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzEditHighlightWindowController.h"
#import "eazesportzSelectGameWindowController.h"
#import "eazesportzSelectPlayerWindowController.h"
#import "eazesportzGetGame.h"
#import "eazesportzUploadHighlight.h"

@interface eazesportzEditHighlightWindowController ()

@property (nonatomic, strong) IBOutlet eazesportzSelectGameWindowController *selectGameController;
@property (nonatomic, strong) IBOutlet eazesportzSelectPlayerWindowController *selectPlayerController;

@end

@implementation eazesportzEditHighlightWindowController {
    NSMutableArray *logs;
}

@synthesize user;
@synthesize sport;
@synthesize game;
@synthesize team;
@synthesize players;
@synthesize getPlayers;
@synthesize gamelog;

@synthesize clipname;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)loadWindow {
    [super loadWindow];
    
    players = [[NSMutableArray alloc] init];
    _highlightNameTextField.stringValue = clipname;
    _teamLabel.stringValue = team.team_name;
    
    if (game) {
        _gameButton.enabled = NO;
        _gameTextField.stringValue = [game vsOpponent];
    }
    
    if (![sport.name isEqualToString:@"Football"]) {
        _gamelogComboBox.hidden = YES;
        _playtagLabel.hidden = YES;
    } else {
        if (game) { // get latest game data for game log stats
            game = [[[eazesportzGetGame alloc] init] getGameSynchronous:sport Team:team Game:game.id User:user];
            _gameTextField.stringValue = [game vsOpponent];
            [self populateGameLog];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameSelected:) name:@"GameSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerSelected:) name:@"PlayerSelectedNotification" object:nil];
    self.selectPlayerController = [[eazesportzSelectPlayerWindowController alloc] initWithWindowNibName:@"eazesportzSelectPlayerWindowController"];
    self.selectPlayerController.getPlayers = getPlayers;
}

- (IBAction)saveButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HighlightsDataUpdtedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self close];
}

- (IBAction)gameButtonClicked:(id)sender {
    self.selectGameController = [[eazesportzSelectGameWindowController alloc] initWithWindowNibName:@"eazesportzSelectGameWindowController"];
    self.selectGameController.sport = sport;
    self.selectGameController.user = user;
    self.selectGameController.team = team;
    [self.selectGameController showWindow:self];
}

- (void)gameSelected:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Result"] isEqualToString:@"Success"]) {
        
        if ([sport.name isEqualToString:@"Football"])
            game = self.selectGameController.game;
        
        [self populateGameLog];
        _gameTextField.stringValue = [game vsOpponent];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"%@", [[notification userInfo] objectForKey:@"Result"]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)populateGameLog {
    logs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < game.gamelogs.count; i++) {
        [logs addObject:[game.gamelogs objectAtIndex:i]];
    }
    
    [_gamelogComboBox reloadData];
}

- (IBAction)playerButtonClicked:(id)sender {
    self.selectPlayerController.sport = sport;
    self.selectPlayerController.user = user;
    self.selectPlayerController.team = team;
    [self.selectPlayerController showWindow:self];
}

- (void)playerSelected:(NSNotification *)notification {
    [players addObject:self.selectPlayerController.player];
    [_playerTagsComboBox reloadData];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    if (aComboBox == _gamelogComboBox)
        return [logs count];
    else
        return players.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if (aComboBox == _gamelogComboBox) {
        return [[logs objectAtIndex:index] logentrytext];
    } else {
        return [[players objectAtIndex:index] full_name];
    }
}
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if ((NSComboBox *)[notification object] == _gamelogComboBox) {
        NSLog(@"[%@ %@] value == %@", NSStringFromClass([self class]),
              NSStringFromSelector(_cmd), [logs objectAtIndex:
                                       [(NSComboBox *)[notification object] indexOfSelectedItem]]);
        Gamelogs *log = [logs objectAtIndex:[(NSComboBox *)[notification object] indexOfSelectedItem]];
        gamelog = log;
        [players addObject:[getPlayers findAthleteById:log.player]];
        
        if (log.assistplayer.length > 0) {
            [players addObject:[getPlayers findAthleteById:log.assistplayer]];
        }
        [_playerTagsComboBox reloadData];
    }
}

@end
