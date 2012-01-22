/*
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by 
 the Free Software Foundation, either version 3 of the License, or any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License 
 along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 
 Created by Takuya Chaen on 2012/01/18.
 Copyright (c) 2012年 Offlab All rights reserved.
 */
//  ViewController.m
//  SpreadUtil


#import "ViewController.h"

@implementation ViewController

@synthesize SpreadSheetService;
@synthesize SpreadsheetFeedEntry;
@synthesize LoadingView;
@synthesize navigationBar;
@synthesize UserInfo;
@synthesize AllArray;
@synthesize LoadingIndicator;
@synthesize TextEditView;
@synthesize SettigView;
@synthesize SaveSettingBt;
@synthesize CloseSettingBt;
@synthesize UserField;
@synthesize PassField;
@synthesize UserLabel;
@synthesize PassLabel;
@synthesize TableView;
@synthesize SpreadImage;
@synthesize InputView;
@synthesize WorkSheetView;
@synthesize WorkSheetPicker;
@synthesize Toolbar;
@synthesize EditTextView;
@synthesize InternalShowBuffer;
@synthesize InternalListArr;
@synthesize InternalListFeedArr;
@synthesize InternalWorkSheetArr;
@synthesize InternalWorksheetTitle;
@synthesize InternalSpreadSheetEntryArr;
@synthesize InternalSpreadSheetTitleArr;


-(void)RemoveAllDat {
    [InternalListArr removeAllObjects];
    [InternalWorksheetTitle removeAllObjects];
    [InternalWorkSheetArr removeAllObjects];
    [InternalSpreadSheetEntryArr removeAllObjects];
    [InternalSpreadSheetTitleArr removeAllObjects];
    [InternalShowBuffer removeAllObjects];
    [InternalListFeedArr removeAllObjects];
}

-(void)HomeRefresh {
    WorkSheetIndexForAdd = -1;
    GetWorksheetFlag = -1;
    ListGettedflag = -1;
    CurrentWorkSheetIndex = -1;
    CurrentDatIndex = 0;
    [self RemoveAllDat];
    LoadingView.hidden = FALSE;
    [LoadingIndicator startAnimating];
    [self Initial_GetSpreadSheetFeed];
}

-(NSMutableArray *)GetElementList {
    NSMutableArray *ElementList = [[NSMutableArray alloc]init];
    NSMutableArray *Rowbuf = [InternalListArr objectAtIndex:CurrentDatIndex];
    for(NSInteger i=0;i<[Rowbuf count];i++) {
        NSMutableArray *Dat = [Rowbuf objectAtIndex:i];
        [ElementList addObject:[Dat objectAtIndex:0]];
    }
    return ElementList;
}

- (void)listFeedUpdateTickets:(GDataServiceTicket *)ticket
          finishedWithEntries:(GDataFeedBase *)feed
                        error:(NSError *)error {
    LoadingView.hidden = TRUE;
    [LoadingIndicator stopAnimating];
    if(error == nil) {
    } else {
    }
    
}

-(void)SaveDat {
    GDataEntrySpreadsheetList *listEntry = [InternalListFeedArr objectAtIndex:CurrentDatIndex];
    NSMutableArray *AddArray = [[NSMutableArray alloc]init];
    NSMutableArray *Elements = [self GetElementList];
    for(NSInteger i=0;i<[Elements count];i++) {
        GDataSpreadsheetCustomElement *UploadElement = 
        [GDataSpreadsheetCustomElement elementWithName:[Elements objectAtIndex:i] stringValue:[InternalShowBuffer objectAtIndex:i]];
        [AddArray addObject:UploadElement];
    }
    [listEntry setCustomElements:AddArray];
    [SpreadSheetService fetchEntryByUpdatingEntry:listEntry delegate:self didFinishSelector:@selector(listFeedUpdateTickets:finishedWithEntries:error:)];
    LoadingView.hidden = FALSE;
    [LoadingIndicator startAnimating];
}   

- (void)listInsertTicket:(GDataServiceTicket *)ticket
         finishedWithEntries:(GDataFeedBase *)feed
                       error:(NSError *)error {
    LoadingView.hidden = TRUE;
    [LoadingIndicator stopAnimating];
    if(error == nil) {
        GDataEntrySpreadsheetList *listEntry = (GDataEntrySpreadsheetList *)feed;
        [InternalListFeedArr addObject:listEntry];
        NSDictionary *customElements = [listEntry customElementDictionary];
        NSEnumerator *enumerator = [customElements objectEnumerator];
        NSMutableArray *Row = [[NSMutableArray alloc]init];
        GDataSpreadsheetCustomElement *element;
        while((element = [enumerator nextObject]) != nil) {
            NSMutableArray *Dat = [[NSMutableArray alloc]init];
            [Dat addObject:[element name]];
            [Dat addObject:[element stringValue]];
            [Row addObject:Dat];
        }
        [InternalListArr addObject:Row];//追加
        CurrentDatIndex = [InternalListArr count]-1;//追加
    } else { 
    }
}

-(void)InsertRow {
    GDataEntryWorksheet *sheet = [InternalWorkSheetArr objectAtIndex:CurrentWorkSheetIndex];
    NSMutableArray *AddArray = [[NSMutableArray alloc]init];
    NSMutableArray *Elements = [self GetElementList];
    
    for(NSInteger i=0;i<[Elements count];i++) {
        GDataSpreadsheetCustomElement *UploadElement =
        [GDataSpreadsheetCustomElement elementWithName:[Elements objectAtIndex:i] stringValue:[InternalShowBuffer objectAtIndex:i]];
        [AddArray addObject:UploadElement];
    }
    GDataEntrySpreadsheetList *listEntry = [GDataEntrySpreadsheetList listEntry];
    [listEntry setCustomElements:AddArray];
    [SpreadSheetService fetchEntryByInsertingEntry:listEntry forFeedURL:[sheet listFeedURL] delegate:self didFinishSelector:@selector(listInsertTicket:finishedWithEntries:error:)];
    LoadingView.hidden = FALSE;
    [LoadingIndicator startAnimating];
}

-(void)RefreshDatListView:(NSInteger )TableViewIndex:(NSString *)ChangeDat {
    NSMutableArray *GetArr = [InternalListArr objectAtIndex:CurrentDatIndex];
    NSMutableArray *GetDat = [GetArr objectAtIndex:TableViewIndex];
    [GetDat replaceObjectAtIndex:1 withObject:ChangeDat];
    [GetArr replaceObjectAtIndex:TableViewIndex withObject:GetDat];
    [InternalListArr replaceObjectAtIndex:CurrentDatIndex withObject:GetArr];
    [TableView reloadData];
    [self SetShowbuffer];
}

-(void)OpenEdit:(NSInteger )Index {
    CurrentChangeIndex = Index;
    TextEditView.text = [InternalShowBuffer objectAtIndex:Index];
    [EditTextView show];
}

-(void)CloseEdit {
    [EditTextView dismissWithClickedButtonIndex:0 animated:YES];
    [self RefreshDatListView:CurrentChangeIndex :TextEditView.text];
}

-(void)NextDat {
    if(ListGettedflag == LIST_GET && 
       [InternalListArr count] > 0) {          
        if(CurrentDatIndex +1 == [InternalListArr count]) {
            return ;
        } else {
            CurrentDatIndex++;
            [self SetShowbuffer];
            [TableView reloadData];
        }
    }
}

-(void)BackDat {
    if(ListGettedflag == LIST_GET && 
       [InternalListArr count] > 0) {  
        if(CurrentDatIndex -1 < 0) {
            return ;
        } else {
            CurrentDatIndex--;
            [self SetShowbuffer];
            [TableView reloadData];
        }
    }
}

-(void)CloseSetting {
    OpenSettingFlag = -1;
    [SettigView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)SaveUserInfo {
    OpenSettingFlag = -1;
    [SettigView dismissWithClickedButtonIndex:0 animated:YES];
    [self SaveInfo];
}

-(void)SaveInfo {
    if(UserField.text == nil | PassField.text == nil) {
        return ;
    }
    UserInfo = [[NSMutableArray alloc]init ];
    [UserInfo addObject:@"Name"];
    [UserInfo addObject:UserField.text];
    [UserInfo addObject:PassField.text];
    
    NSArray *Path = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[Path objectAtIndex:0] 
                          stringByAppendingPathComponent:@"Name"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSString *temp = @"Name:name@gmail.com:Pass";
        [temp writeToFile:dataPath atomically:NO
                 encoding:NSUTF8StringEncoding
                    error:nil
         ];
        [UserInfo addObject:@"Name"];
        [UserInfo addObject:@"name@gmail.com"];
        [UserInfo addObject:@"Pass"];
    } else {
        NSFileManager *FileManage = [NSFileManager defaultManager];
        [FileManage removeItemAtPath:dataPath error:nil]; 
        NSString *temp = [[NSString alloc]initWithFormat: @"%@:%@:%@" , 
                          [UserInfo objectAtIndex:0]
                          ,[UserInfo objectAtIndex:1]
                          ,[UserInfo objectAtIndex:2]];
        [temp writeToFile:dataPath atomically:NO
                 encoding:NSUTF8StringEncoding error:nil];
    }
}

-(void)GetUserInfo {
    NSError *error;
    int i;
    UserInfo = [[NSMutableArray alloc]init];
    NSArray *Path = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataPath = [[Path objectAtIndex:0] 
                          stringByAppendingPathComponent:@"Name"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSString *temp = @"Name:Name@gmail.com:Pass";
        [temp writeToFile:dataPath atomically:NO
                 encoding:NSUTF8StringEncoding
                    error:nil
         ];
        [UserInfo addObject:@"Name"];
        [UserInfo addObject:@"Name@gmail.com"];
        [UserInfo addObject:@"Pass"];
    } else {
        NSString* text = [NSString stringWithContentsOfFile:dataPath 
                                                   encoding:NSUTF8StringEncoding 
                                                      error:&error];
        NSArray* lines = [text componentsSeparatedByString:@":"];
        
        for(i=0;i<3;i++) {
            [UserInfo addObject:[lines objectAtIndex:i]];
        }
    }
}

-(void)OpenSetting {
    [self GetUserInfo];
    
    UserField.text = [UserInfo objectAtIndex:1];
    PassField.text = [UserInfo objectAtIndex:2];
    
    OpenSettingFlag = OPEN_SETTING;
    [SettigView show];
}

-(void)willPresentAlertView:
(UIAlertView *)alertView {  
    CGRect AlertFrame;
    if(OpenSettingFlag == OPEN_SETTING) {
        AlertFrame = CGRectMake(20,50,270,260);  
        alertView.frame = AlertFrame;
        return ;
    }    
    if(ListGettedflag == LIST_GET) {
        AlertFrame = CGRectMake(10, 20, 300, 240);
        alertView.frame = AlertFrame;
        return ;
    }
    if(GetWorksheetFlag == GETTING_WORKSHEET) {
        AlertFrame = CGRectMake(20, 50, 250, 300);
        alertView.frame = AlertFrame;
        return ;
    }

}

-(void)InitSettingView {
    SettigView = [[UIAlertView alloc]initWithTitle:@" " message:@" "
                                          delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];    
    
    EditTextView = [[UIAlertView alloc]initWithTitle:@" " message:@" " delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    EditTextView.delegate = self;
    TextEditView = [[UITextView alloc]initWithFrame:CGRectMake(20, 20, 260, 130)];
    [EditTextView addSubview:TextEditView];
    UIButton *CloseButton = [[UIButton alloc]initWithFrame:CGRectMake(120, 170, 60, 60)];
    [CloseButton setBackgroundImage:[UIImage imageNamed:@"Down_.png"] forState:UIControlStateNormal];
    [CloseButton addTarget:self action:@selector(CloseEdit) forControlEvents:UIControlEventTouchUpInside];
    [EditTextView addSubview:CloseButton];
    [CloseButton release];
    SaveSettingBt = [[UIButton alloc]initWithFrame:CGRectMake(40,180,60,60)];
    [SaveSettingBt setBackgroundImage:[UIImage imageNamed:@"Down_.png"]
                             forState:UIControlStateNormal];
    [SaveSettingBt addTarget:self action:@selector(SaveUserInfo)
            forControlEvents:UIControlEventTouchUpInside];
    
    CloseSettingBt = [[UIButton alloc]initWithFrame:CGRectMake(180, 180, 60, 60)];
    [CloseSettingBt setBackgroundImage:[UIImage imageNamed:@"x.png"] 
                              forState:UIControlStateNormal];
    [CloseSettingBt addTarget:self action:@selector(CloseSetting) 
             forControlEvents:UIControlEventTouchUpInside];
    UserLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 60, 30)];
    UserLabel.text = @"User";
    UserLabel.textColor = [UIColor whiteColor];
    [UserLabel setBackgroundColor:[UIColor clearColor]];
    PassLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 80, 60, 30)];
    PassLabel.text = @"Pass";
    PassLabel.textColor = [UIColor whiteColor];
    [PassLabel setBackgroundColor:[UIColor clearColor]];
    UserField = [[UITextField alloc]initWithFrame:CGRectMake(60, 20, 180, 40)];
    PassField = [[UITextField alloc]initWithFrame:CGRectMake(60, 80, 180, 40)];
    UserField.borderStyle = UITextBorderStyleRoundedRect;
    PassField.borderStyle = UITextBorderStyleRoundedRect;
    PassField.secureTextEntry = YES;
    [SettigView addSubview:SaveSettingBt];
    [SettigView addSubview:CloseSettingBt];
    [SettigView addSubview:UserField];
    [SettigView addSubview:PassField];
    [SettigView addSubview:UserLabel];
    [SettigView addSubview:PassLabel];
}

-(void)Init_Array {
    UserInfo = [[NSMutableArray alloc]init];
    InternalSpreadSheetEntryArr = [[NSMutableArray alloc]init];
    InternalSpreadSheetTitleArr = [[NSMutableArray alloc]init];
    InternalWorksheetTitle = [[NSMutableArray alloc]init];
    InternalWorkSheetArr = [[NSMutableArray alloc]init];
    InternalListArr = [[NSMutableArray alloc]init];    
    InternalShowBuffer = [[NSMutableArray alloc]init];
    InternalListFeedArr = [[NSMutableArray alloc]init];
}


-(void)LoadView {
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = [[UIScreen mainScreen] applicationFrame];
        
    Toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 420, 320, 40)];
    [Toolbar setBarStyle:UIBarStyleDefault];
    [contentView addSubview:Toolbar];
    UIBarButtonItem *NextButton = [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(NextDat)];
    UIBarButtonItem *BackButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(BackDat)];
    UIBarButtonItem *SaveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(SaveDat)];
    UIBarButtonItem *NewButton = [[UIBarButtonItem alloc]initWithTitle:@"New" style:UIBarButtonItemStyleBordered target:self action:@selector(InsertRow)];
    UIBarButtonItem *HomeButton = [[UIBarButtonItem alloc]initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(HomeRefresh)];
    NSArray *Items = [NSArray arrayWithObjects:BackButton,NextButton 
                      ,SaveButton,NewButton,HomeButton, nil];
    Toolbar.items = Items;
    navigationBar = [[UINavigationBar alloc] init];
    navigationBar.frame = CGRectMake(0.0 , 0.0, contentView.frame.size.width, 40);
    UINavigationItem *itemForNavigationBar0 = [[UINavigationItem alloc] init];
    itemForNavigationBar0.title = @"";
    UIBarButtonItem *leftButtonForNavigationBar0 = [[UIBarButtonItem alloc] initWithTitle:@"Acount" style:UIBarButtonItemStyleBordered target:nil action:@selector(OpenSetting)];
    itemForNavigationBar0.leftBarButtonItem = leftButtonForNavigationBar0;
    [leftButtonForNavigationBar0 release];
    [navigationBar pushNavigationItem:itemForNavigationBar0 animated:NO];
    [itemForNavigationBar0 release];
    [contentView addSubview:navigationBar];
    
    TableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, 320, 380) style:UITableViewStylePlain];
    [contentView addSubview:TableView];
    TableView.delegate = self;
    TableView.dataSource = self;
    [self InitSettingView];
    [self InitWorksheetView];
    LoadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    LoadingIndicator.frame = CGRectMake(140, 200, 50, 50);
    [LoadingIndicator startAnimating];
    
    UILabel *LoadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 240, 100, 30)];
    LoadingLabel.text = @"Loading...";
    LoadingLabel.textColor = [UIColor whiteColor];
    LoadingLabel.backgroundColor = [UIColor clearColor];
    
    LoadingView = [[UIView alloc]init];
    CGRect LoadingViewRect = contentView.frame;
    LoadingViewRect.origin.y = 0;
    LoadingViewRect.size.height += 20;
    LoadingView.frame = LoadingViewRect;
    [LoadingView setBackgroundColor:[UIColor blackColor]];
    [LoadingView setAlpha:0.70];
    [LoadingView addSubview:LoadingLabel];
    LoadingView.hidden = FALSE;
    [LoadingView addSubview:LoadingIndicator];
    [contentView addSubview:LoadingView];
    self.view = contentView;
    [contentView release];
}

-(void)SetShowbuffer {
    [InternalShowBuffer removeAllObjects];
    NSMutableArray *RowBuf = [InternalListArr objectAtIndex:CurrentDatIndex];
    for(NSInteger i=0;i<[RowBuf count];i++) {
        NSMutableArray *Dat = [RowBuf objectAtIndex:i];
        [InternalShowBuffer addObject:[Dat objectAtIndex:1]];
    }
}

- (void)entriesTicketForWorkSheetList:(GDataServiceTicket *)ticket
                     finishedWithFeed:(GDataFeedBase *)feed
                                error:(NSError *)error {
    LoadingView.hidden = TRUE;
    [LoadingIndicator stopAnimating];
    if(error == nil) {
        NSArray *Ret = [feed entries];
        if([Ret count] < 1) {
            return;
        }
        for (NSInteger i=0; i< [Ret count]; i++) {
            GDataEntryBase *entry = [[feed entries] objectAtIndex:i];
            NSMutableArray *Row = [[NSMutableArray alloc]init];
            if([entry isKindOfClass:[GDataEntrySpreadsheetCell class]]) {
            } else {
                GDataEntrySpreadsheetList *listEntry = (GDataEntrySpreadsheetList *)entry;
                [InternalListFeedArr addObject:listEntry];
                NSDictionary *customElements = [listEntry customElementDictionary];
                NSEnumerator *enumerator = [customElements objectEnumerator];
                GDataSpreadsheetCustomElement *element;
                while((element = [enumerator nextObject]) != nil) {
                    NSMutableArray *Dat = [[NSMutableArray alloc]init];
                    [Dat addObject:[element name]];
                    [Dat addObject:[element stringValue]];
                    [Row addObject:Dat];
                }
                [InternalListArr addObject:Row];
            }
        }
        [self SetShowbuffer];
        ListGettedflag = LIST_GET;
        [TableView reloadData];
    }
}

-(void)GetWorkSheetList:(GDataEntryWorksheet *)WorkSheet {
    LoadingView.hidden = FALSE;
    [LoadingIndicator startAnimating];
    NSURL *ListUrl = [WorkSheet listFeedURL];
    [SpreadSheetService fetchFeedWithURL:ListUrl delegate:self didFinishSelector:@selector(entriesTicketForWorkSheetList:finishedWithFeed:error:)];
}

-(void)CloseWorksheetView {
    [WorkSheetView dismissWithClickedButtonIndex:0 animated:YES];
    GetWorksheetFlag = -1;
    CurrentWorkSheetIndex = [WorkSheetPicker selectedRowInComponent:0];
    [self GetWorkSheetList:[InternalWorkSheetArr 
                            objectAtIndex:[WorkSheetPicker selectedRowInComponent:0]]];
}

-(void)ShowWorkSheetView {
    [WorkSheetView show];
}

- (void)worksheetTicket:(GDataServiceTicket *)ticket
       finishedWithFeed:(GDataFeedWorksheet *)feed
                  error:(NSError *)error {
    LoadingView.hidden = TRUE;
    [LoadingIndicator stopAnimating];
    if(error == nil) {
        int i;
        NSArray *SheetArr = [feed entries];
        for(i=0;i<[SheetArr count];i++) {
            GDataEntryWorksheet *WorkSheet = [SheetArr objectAtIndex:i];
            NSString *GetTitle = [[WorkSheet title]stringValue];
            [InternalWorkSheetArr addObject:WorkSheet];
            [InternalWorksheetTitle addObject:GetTitle];
        }
        [self ShowWorkSheetView];
    } else {
        NSLog(@"err");
    }
}

-(void)GetWorkSheetFeedWithIndex:(NSInteger)clickindex {
    LoadingView.hidden = FALSE;
    [LoadingIndicator startAnimating];
    GDataEntrySpreadsheet *SpreadSheet = [InternalSpreadSheetEntryArr objectAtIndex:clickindex];
    NSURL *WorkSheetURL = [SpreadSheet worksheetsFeedURL];
    GDataServiceTicket *Ticket;
    Ticket = [SpreadSheetService fetchFeedWithURL:WorkSheetURL delegate:self
                                didFinishSelector:@selector(worksheetTicket:finishedWithFeed:error:)];
}

-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedGetFlag = -1;
    if(ListGettedflag == LIST_GET ) {
        [self OpenEdit:indexPath.row];
    }
    if(indexPath.row < [InternalSpreadSheetEntryArr count]
       && GetWorksheetFlag == GETTING_WORKSHEET) {
        [self GetWorkSheetFeedWithIndex:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
 	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:CellIdentifier] 
                autorelease];
    }
    if(ListGettedflag == LIST_GET ) {
        NSMutableArray *GetArr = [InternalListArr objectAtIndex:CurrentDatIndex];
        NSMutableArray *GetDat = [GetArr objectAtIndex:indexPath.row];
        cell.textLabel.text = [[NSString alloc]initWithFormat:@"%@ : %@",[GetDat objectAtIndex:0],[GetDat objectAtIndex:1]];
        cell.imageView.image = nil;
        return cell;
        
    }
    if(FeedGetFlag == FEED_INIT) {
        if([InternalSpreadSheetTitleArr count] > 0 ){
            cell.textLabel.text = [InternalSpreadSheetTitleArr objectAtIndex:indexPath.row];
            cell.imageView.image = SpreadImage;
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section{
    
    if([InternalListArr count] > 0 && ListGettedflag == LIST_GET) {
        NSMutableArray *GetArr = [InternalListArr objectAtIndex:CurrentDatIndex];
        return [GetArr count];
    }
    if([InternalSpreadSheetTitleArr count] > 0 ){
        return [InternalSpreadSheetTitleArr count];
    }
    return 0;
}

-(void)setupSpreadSheetService:(NSString*)username password:(NSString*)password {
    SpreadSheetService = [[GDataServiceGoogleSpreadsheet alloc] init];
    [SpreadSheetService setServiceShouldFollowNextLinks:YES];
    [SpreadSheetService setShouldCacheResponseData:YES];
    [SpreadSheetService setUserCredentialsWithUsername:username password:password];
}

-(GDataServiceGoogleSpreadsheet *)GetSpreadSheetService:(NSString*)username password:(NSString*)password {
    GDataServiceGoogleSpreadsheet *Service = [[GDataServiceGoogleSpreadsheet alloc] init];
    [Service setServiceShouldFollowNextLinks:YES];
    [Service setUserCredentialsWithUsername:username password:password];
    return Service;
}

-(void)HandleSpreadSheetFeedInitial { 
    NSArray *SpreadSheetArray = [SpreadsheetFeedEntry entries];
    NSInteger EntryCount = [SpreadSheetArray count];
    int i;
    if(EntryCount == 0) {
    } else {
        for(i=0;i<EntryCount;i++) {            
            GDataEntrySpreadsheet *spreadsheetEntry = [SpreadSheetArray objectAtIndex:i];
            [InternalSpreadSheetEntryArr addObject:spreadsheetEntry];
            GDataTextConstruct *Title = [spreadsheetEntry title];
            NSString *TitleStr = [Title stringValue];
            [InternalSpreadSheetTitleArr addObject:TitleStr];
        }        
        GetWorksheetFlag = GETTING_WORKSHEET;
        LoadingView.hidden = TRUE;
        [LoadingIndicator stopAnimating];
        [TableView reloadData];
    }
}

-(void)InitImages {
    SpreadImage = [UIImage imageNamed:@"excel.png"];
}

-(void)ShowNetworkAlert {
    UIAlertView *NetWorkAlert = [[[UIAlertView alloc]initWithTitle:@"Error" 
                                                           message:@"NetworkError Occured" delegate:nil 
                                                 cancelButtonTitle:nil otherButtonTitles:@"OK", nil]autorelease];
    [NetWorkAlert show];
    LoadingView.hidden = TRUE;
    [LoadingIndicator stopAnimating];
}

-(NSInteger)numberOfComponentsInPickerView:
(UIPickerView*)pickerView {
    return 1;
}

-(NSInteger)pickerView:
(UIPickerView*)pickerView numberOfRowsInComponent:
(NSInteger)component {
    return [InternalWorksheetTitle count];
}

-(NSString*)pickerView:
(UIPickerView*)pickerView
           titleForRow:(NSInteger)row
          forComponent:(NSInteger)component {
    NSString *PickerStr;
    if([InternalWorksheetTitle count] > 0 ) {
        PickerStr = [InternalWorksheetTitle objectAtIndex:row];
    } else {
        PickerStr = @"";
    }
    return PickerStr;
}

-(void)InitWorksheetView {
    WorkSheetView = [[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    WorkSheetPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(20, 20, 210, 180)];
    WorkSheetPicker.delegate = self;
    WorkSheetPicker.dataSource = self;
    WorkSheetPicker.showsSelectionIndicator = YES;
    UIButton *CloseAlertViewBt = [[UIButton alloc]initWithFrame:CGRectMake(85, 210, 70, 70)];
    [CloseAlertViewBt setBackgroundImage:[UIImage imageNamed:@"Down_.png"] forState:UIControlStateNormal];
    [CloseAlertViewBt addTarget:self action:@selector(CloseWorksheetView) forControlEvents:UIControlEventTouchUpInside];
    [WorkSheetView addSubview:CloseAlertViewBt];
    [WorkSheetView addSubview:WorkSheetPicker];    
    [CloseAlertViewBt release];    
}

- (void)spreadsheetsTicketForInit:(GDataServiceTicket *)ticket
                 finishedWithFeed:(GDataFeedSpreadsheet *)feed
                            error:(NSError *)error {
    if (error == nil) {
        SpreadsheetFeedEntry = feed;
        [self HandleSpreadSheetFeedInitial];
    } else {
        [self ShowNetworkAlert];            
    }
}

-(void)GetSpreadSheetFeed:(NSString *)UserName 
                 password:(NSString *)Password {
    [self setupSpreadSheetService:UserName password:Password];
    GDataServiceTicket *ticket;
    NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
    if(FeedGetFlag == FEED_INIT) {
        ticket = [SpreadSheetService fetchFeedWithURL:feedURL delegate:self 
                                    didFinishSelector:
                  @selector(spreadsheetsTicketForInit:finishedWithFeed:error:)];
    }
}

-(void)Initial_GetSpreadSheetFeed {
    [self GetUserInfo];
    NSString *User = [UserInfo objectAtIndex:1];
    NSString *Pass = [UserInfo objectAtIndex:2];
    FeedGetFlag = FEED_INIT;
    [self GetSpreadSheetFeed:User password:Pass];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)ClearFlags {
    GetWorksheetFlag = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ClearFlags];
    
    WorkSheetIndexForAdd = -1;
    CurrentDatIndex = 0;
    
    [self Init_Array];
    [self InitImages];
    [self LoadView];
    
    [self Initial_GetSpreadSheetFeed];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [SpreadSheetService release];
    [SpreadsheetFeedEntry release];
    [LoadingView release];
    [navigationBar release];
    [UserInfo release];
    [AllArray release];
    [LoadingIndicator release];
    [TextEditView release];
    [SettigView release];
    [SaveSettingBt release];
    [CloseSettingBt release];
    [UserField release];
    [PassField release];
    [UserLabel release];
    [PassLabel release];
    [TableView release];
    [SpreadImage release];
    [InputView release];
    [WorkSheetPicker release];
    [WorkSheetView release];
    [Toolbar release];
    [EditTextView release];
    [InternalShowBuffer release];
    [InternalListArr release];
    [InternalListFeedArr release];
    [InternalWorkSheetArr release];
    [InternalWorksheetTitle release];
    [InternalSpreadSheetEntryArr release];
    [InternalSpreadSheetTitleArr release];    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
    //    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
