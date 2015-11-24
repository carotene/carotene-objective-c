//
//  CRTNViewController.m
//  carotene
//
//  Created by nacho on 11/24/2015.
//  Copyright (c) 2015 nacho. All rights reserved.
//

#import "CRTNViewController.h"
#import <Carotene/CRTNCarotene.h>

@interface CRTNViewController ()

@end

@implementation CRTNViewController {
    CRTNCarotene *carotene;
    NSMutableArray *_messages;
}

@synthesize textInput = _textInput;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _messages = [[NSMutableArray alloc] init];

    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    [_textInput becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    carotene = [[CRTNCarotene alloc] init:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:8081/stream"]]];
    [carotene subscribe:@"chat" handleWithBlock:^(NSString *msg){
        [self display:msg];
    }];

}

- (void) display:(NSString *)messageRaw
{
    NSDictionary *messageJson;
    NSError *jsonError;
    messageJson = [NSJSONSerialization JSONObjectWithData:[messageRaw dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    NSLog(@"messageJson \"%@\"", messageJson);
    [_messages addObject:[messageJson objectForKey:@"msg"]];
    NSLog(@"messageJson \"%@\"", messageJson);
    
    NSLog(@"Messages available after update %lu", _messages.count);
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    NSLog(@"Dimensions %f", self.tableView.tableFooterView.frame.size.height);
    
    UIEdgeInsets tableInsets = self.tableView.contentInset;
    CGFloat tableHeight = self.tableView.frame.size.height - tableInsets.bottom - tableInsets.top;
    CGFloat bottom = CGRectGetMaxY(self.tableView.tableFooterView.frame);
    CGFloat offset = bottom - tableHeight;
    if(offset > 0.f) {
        [self.tableView setContentOffset:CGPointMake(0,  offset) animated:YES];
    }


}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewController


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSLog(@"Messages available %lu", _messages.count);
    return _messages.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.textLabel.text = [_messages objectAtIndex:indexPath.row];
    
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_messages objectAtIndex:indexPath.row];
    return cell;

}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        NSString *rawMsg = [[textView.text stringByReplacingCharactersInRange:range withString:text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSDictionary *dictText = @{
                                   @"msg" : rawMsg,
                                   };
        

        [carotene publish:dictText channel:@"chat"];

        textView.text = @"";
        
        return NO;
    }
    return YES;
}

@end

