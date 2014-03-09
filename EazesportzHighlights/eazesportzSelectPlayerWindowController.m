//
//  eazesportzSelectPlayerWindowController.m
//  EazesportzHighlights
//
//  Created by Gil on 3/8/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzSelectPlayerWindowController.h"

@interface eazesportzSelectPlayerWindowController ()

@end

@implementation eazesportzSelectPlayerWindowController {
    NSMutableArray *roster;
}

@synthesize sport;
@synthesize team;
@synthesize user;
@synthesize getPlayers;
@synthesize player;

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
    roster = [[NSMutableArray alloc] init];
    
    if (!getPlayers) {
        getPlayers = [[EazesportzRetrievePlayers alloc] init];
        [getPlayers retrievePlayers:sport Team:team User:user];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotRoster:) name:@"RosterChangedNotification" object:nil];
    } else {
        roster = getPlayers.roster;
        [_playerTableView reloadData];
    }
}

- (void)gotRoster:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Result"] isEqualToString:@"Success"]) {
        roster = getPlayers.roster;
        [_playerTableView reloadData];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"%@", [[notification userInfo] objectForKey:@"Result"]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (IBAction)searchButtonClicked:(id)sender {
    if (_numberTextField.stringValue.length > 0) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        Athlete *aplayer = [self findAthleteByNumber:[f numberFromString:_numberTextField.stringValue]];
        roster = [[NSMutableArray alloc] initWithObjects:aplayer, nil];
    } else {
        roster = [self findAthleteByPosition:_positionTextField.stringValue];
    }
    [_playerTableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    Athlete *anathlete = [roster objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"NumberTableColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"NumberTableCell" owner:self];
        cellView.textField.stringValue = [anathlete.number stringValue];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"NameTableColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"NameTableCell" owner:self];
        cellView.textField.stringValue = [anathlete name];
        return cellView;
    } else {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"PositionTableCell" owner:self];
        cellView.textField.stringValue = anathlete.position;
        return cellView;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return roster.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_playerTableView selectedRow] >= 0) {
        NSInteger playerSelected = [_playerTableView selectedRow];
        player = [getPlayers.roster objectAtIndex:playerSelected];
        [self.window close];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerSelectedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (BOOL)textField:(NSTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _numberTextField) {
        NSString *validRegEx =@"^[0-9.]*$"; //change this regular expression as your requirement
        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
        if (myStringMatchesRegEx)
            return YES;
        else
            return NO;
    } else
        return YES;
}

- (Athlete *)findAthleteByNumber:(NSNumber *)number {
    Athlete *result = nil;
    for (int cnt = 0; cnt < [roster count]; cnt++) {
        if ([[[roster objectAtIndex:cnt] number] intValue] == [number intValue]) {
            result = [roster objectAtIndex:cnt];
        }
    }
    return result;
}

- (NSMutableArray *)findAthleteByPosition:(NSString *)position {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int cnt = 0; cnt < [roster count]; cnt++) {
        Athlete *ath = [roster objectAtIndex:cnt];
        NSArray *listItems = [[ath position] componentsSeparatedByString:@"/"];
        for (int cnt = 0; cnt < [listItems count]; cnt++) {
            NSString *item = [listItems objectAtIndex:cnt];
            if ([item caseInsensitiveCompare:position] == NSOrderedSame) {
                [result addObject:ath];
            }
        }
    }
    return result;
}

- (IBAction)reloadButtonClicked:(id)sender {
    roster = getPlayers.roster;
    [_playerTableView reloadData];
}

@end
