
/**
 *  SFNDatePicker.m
 *  Created by Siksfonine on 2015.02.10
 *
 *  Self -> Scroll view -> Weekday symbols view & (Dates view -> Dates view left, middle and right) & Date label view
 */

#import "SFNDatePicker.h"

#define WEEKDAYSYMBOL_FONT 10.0f
#define DATEBUTTON_FONT 18.0f
#define DATELABEL_FONT 13.0f

@interface SFNDatePicker ()

@property (nonatomic, strong) NSMutableArray *dateButtonsL;
@property (nonatomic, strong) NSMutableArray *dateButtonsM;
@property (nonatomic, strong) NSMutableArray *dateButtonsR;

@property (nonatomic, strong) UIView *datesViewL;
@property (nonatomic, strong) UIView *datesViewM;
@property (nonatomic, strong) UIView *datesViewR;
@property (nonatomic, strong) UIView *weekdaySymbolsView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, assign) NSInteger week;
@property (nonatomic, assign) NSInteger date;

@end

@implementation SFNDatePicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.calendar = [NSCalendar currentCalendar];
        self.week = 0;
        self.date = 0;
        self.dateButtonsL = [NSMutableArray array];
        self.dateButtonsM = [NSMutableArray array];
        self.dateButtonsR = [NSMutableArray array];
        
        [self theScrollView];
        [self theWeekdaySymbolsView];
        [self theDateLabelView];
        [self theDatesView];
        [self theSwipeGestureRecognizer];
    }
    
    return self;
}

#pragma mark - The scroll view

- (void)theScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 65)];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self addSubview:self.scrollView];
}

#pragma mark The weekday symbols view

- (void)theWeekdaySymbolsView
{
    self.weekdaySymbolsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
    
    for (int i = 0; i < self.calendar.shortWeekdaySymbols.count; i++)
    {
        CGFloat width = self.weekdaySymbolsView.frame.size.width / 7;
        UILabel *weekdaySymbol = [[UILabel alloc] initWithFrame:CGRectMake(i * width, 0, width, 10)];
        weekdaySymbol.text = [self.calendar.shortWeekdaySymbols[i] uppercaseString];
        weekdaySymbol.textAlignment = NSTextAlignmentCenter;
        weekdaySymbol.font = [UIFont systemFontOfSize:WEEKDAYSYMBOL_FONT];
        
        [self.weekdaySymbolsView addSubview:weekdaySymbol];
    }
    
    [self.scrollView addSubview:self.weekdaySymbolsView];
}

#pragma mark The dates view

- (void)theDatesView
{
    CGFloat widthOfScrollView = self.scrollView.frame.size.width;
    
    /* Dates view on the left */
    
    self.datesViewL = [[UIView alloc] initWithFrame:CGRectMake(-widthOfScrollView, 12, widthOfScrollView, 30)];
    
    for (int i = 0; i < 7; i++)
    {
        CGFloat width = self.datesViewL.frame.size.width / 7;
        CGFloat space = (self.datesViewL.frame.size.width - 7 * 30) / 14;
        UIButton *dateButton = [[UIButton alloc] initWithFrame:CGRectMake(i * width + space, 0, 30, 30)];
        dateButton.titleLabel.font = [UIFont systemFontOfSize:DATEBUTTON_FONT];
        
        [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dateButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
        [self.dateButtonsL addObject:dateButton];
        [self.datesViewL addSubview:dateButton];
    }
    
    [self.scrollView addSubview:self.datesViewL];
    
    
    /* Dates view in the middle */
    
    self.datesViewM = [[UIView alloc] initWithFrame:CGRectMake(0, 12, widthOfScrollView, 30)];
    
    NSInteger temp = 0;
    for (int i = 0; i < 7; i++)
    {
        CGFloat width = self.datesViewM.frame.size.width / 7;
        CGFloat space = (self.datesViewM.frame.size.width - 7 * 30) / 14;
        UIButton *dateButton = [[UIButton alloc] initWithFrame:CGRectMake(i * width + space, 0, 30, 30)];
        dateButton.titleLabel.font = [UIFont systemFontOfSize:DATEBUTTON_FONT];
        
        [dateButton setTitle:[[self datesArray] objectAtIndex:i] forState:UIControlStateNormal];
        [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dateButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([dateButton.titleLabel.text isEqualToString:[self getCurrentday]])
        {
            [dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [dateButton setBackgroundColor:[UIColor redColor]];
            
            temp = i;
            dateButton.layer.cornerRadius = dateButton.frame.size.width / 2;
            dateButton.layer.masksToBounds = YES;
            dateButton.layer.borderColor = [UIColor clearColor].CGColor;
            dateButton.layer.borderWidth = 0;
            
            self.dateLabel.text = [self getToday];
        }
        
        [self.dateButtonsM addObject:dateButton];
        [self.datesViewM addSubview:dateButton];
    }
    
    for (int i = 0; i < 7; i++)
    {
        UIButton *button = [self.dateButtonsM objectAtIndex:i];
        button.tag = i - temp;
    }
    
    [self.scrollView addSubview:self.datesViewM];
    
    
    /* Dates view on the right */
    
    self.datesViewR = [[UIView alloc] initWithFrame:CGRectMake(widthOfScrollView, 12, widthOfScrollView, 30)];
    
    for (int i = 0; i < 7; i++)
    {
        CGFloat width = self.datesViewR.frame.size.width / 7;
        CGFloat space = (self.datesViewR.frame.size.width - 7 * 30) / 14;
        UIButton *dateButton = [[UIButton alloc] initWithFrame:CGRectMake(i * width + space, 0, 30, 30)];
        dateButton.titleLabel.font = [UIFont systemFontOfSize:DATEBUTTON_FONT];
        
        [dateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dateButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
        [self.dateButtonsR addObject:dateButton];
        [self.datesViewR addSubview:dateButton];
    }
    
    [self.scrollView addSubview:self.datesViewR];
}

- (NSMutableArray *)datesArray
{
    NSMutableArray *dates = [NSMutableArray array];
    
    NSDateComponents *comps = [self getDateComponentsFromDate:[NSDate date] orDayInterval:0];
    
    /* Days in the week */
    for (NSInteger i = 0; i < 7; i++)
    {
        NSDateComponents *temp = [self getDateComponentsFromDate:nil orDayInterval:i + 1 - comps.weekday + self.week * 7];
        [dates addObject:[NSString stringWithFormat:@"%ld", (long)temp.day]];
    }
    
    return dates;
}

- (void)setTitleForDateButtonsOfView:(NSString *)viewName
{
    for (int i = 0; i < 7; i++)
    {
        UIButton *temp = nil;
        
        if ([viewName isEqualToString:@"l"])
        {
            temp = [self.dateButtonsL objectAtIndex:i];
        }
        else if ([viewName isEqualToString:@"m"])
        {
            temp = [self.dateButtonsM objectAtIndex:i];
        }
        else if ([viewName isEqualToString:@"r"])
        {
            temp = [self.dateButtonsR objectAtIndex:i];
        }
        else
        {
            // Nothing here ...
        }
        
        [temp setTitle:[[self datesArray] objectAtIndex:i] forState:UIControlStateNormal];
    }
}

- (void)selectDate:(UIButton *)sender
{
    for (int i = 0; i < 7; i++)
    {
        UIButton *temp = [self.dateButtonsM objectAtIndex:i];
        [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [temp setBackgroundColor:[UIColor clearColor]];
        
        if ([temp.titleLabel.text isEqualToString:sender.titleLabel.text])
        {
            [temp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [temp setBackgroundColor:[UIColor redColor]];
            
            temp.layer.cornerRadius = sender.frame.size.height / 2;
            temp.layer.masksToBounds = YES;
            temp.layer.borderColor = [UIColor clearColor].CGColor;
            temp.layer.borderWidth = 0;
        }
    }
    
    self.date = sender.tag;
    
    [self setDateStringForDateLabel];
}

#pragma mark The date label view

- (void)theDateLabelView
{
    UIView *dateLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, self.scrollView.frame.size.width, 20)];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dateLabelView.frame.size.width, dateLabelView.frame.size.height)];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.font = [UIFont systemFontOfSize:DATELABEL_FONT];
    
    [dateLabelView addSubview:self.dateLabel];
    
    [self.scrollView addSubview:dateLabelView];
}

- (void)setDateStringForDateLabel
{
    self.dateLabel.text = [self getDateStringByDate:nil orDayInterval:self.date + self.week * 7];
}

#pragma mark - The swipe gesture

- (void)theSwipeGestureRecognizer
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeTouch:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    //[self.scrollView addGestureRecognizer:swipeLeft];     #Bug report!
    [self.datesViewM addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeTouch:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    //[self.scrollView addGestureRecognizer:swipeRight];    #Bug report!
    [self.datesViewM addGestureRecognizer:swipeRight];
}

- (void)swipeTouch:(UISwipeGestureRecognizer *)sender
{
    CGRect originalFrameL = self.datesViewL.frame;
    CGRect originalFrameM = self.datesViewM.frame;
    CGRect originalFrameR = self.datesViewR.frame;
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        self.week++;
        [self setTitleForDateButtonsOfView:@"r"];
        
        [UIView animateWithDuration:.649 animations:^{
            
            self.datesViewM.frame = originalFrameL;
            self.datesViewR.frame = originalFrameM;
            
        } completion:^(BOOL finished) {
            
            self.datesViewM.frame = originalFrameM;
            self.datesViewR.frame = originalFrameR;
            
            [self setTitleForDateButtonsOfView:@"m"];
            
            [self setDateStringForDateLabel];

        }];
    }
    else if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        self.week--;
        [self setTitleForDateButtonsOfView:@"l"];
        
        [UIView animateWithDuration:.649 animations:^{
            
            self.datesViewM.frame = originalFrameR;
            self.datesViewL.frame = originalFrameM;
            
        } completion:^(BOOL finished) {
            
            self.datesViewM.frame = originalFrameM;
            self.datesViewL.frame = originalFrameL;
            
            [self setTitleForDateButtonsOfView:@"m"];
            
            [self setDateStringForDateLabel];
            
        }];
    }
    else
    {
        // Nothing here ...
    }
}

#pragma mark - Methods

/* When the 'date' is nil, 'dayInterval' will be used, otherwise it will be ignored */
- (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date orDayInterval:(NSInteger)dayInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = nil;
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    if (date != nil)
    {
        dateComps = [calendar components:units fromDate:date];
    }
    else
    {
        NSDate *dateSinceNow = [NSDate dateWithTimeIntervalSinceNow:dayInterval * 24 * 60 * 60];
        dateComps = [calendar components:units fromDate:dateSinceNow];
    }
    
    return dateComps;
}

- (NSString *)getCurrentday
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:units fromDate:today];
    NSString *currentDay = [NSString stringWithFormat:@"%ld", (long)comps.day];
    return currentDay;
}

- (NSString *)getCurrentMonth
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:units fromDate:today];
    NSString *currentMonth = [NSString stringWithFormat:@"%ld", (long)comps.month];
    return currentMonth;
}

- (NSString *)getCurrentYear
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:units fromDate:today];
    NSString *currentYear = [NSString stringWithFormat:@"%ld", (long)comps.year];
    return currentYear;
}

- (NSString *)getCurrentWeekday
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *comps = [calendar components:units fromDate:today];
    NSString *currentWeekday = [NSString stringWithFormat:@"%ld", (long)comps.weekday];
    return currentWeekday;
}

- (NSString *)getToday
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE MMMM dd, yyyy"];
    NSString *today = [dateFormatter stringFromDate:date];
    
    return today;
}

/* When the 'date' is nil, 'dayInterval' will be used, otherwise it will be ignored */
- (NSString *)getDateStringByDate:(NSDate *)date orDayInterval:(NSInteger)dayInterval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE MMMM dd, yyyy"];
    NSString *dateString = nil;
    
    if (date != nil)
    {
        dateString = [dateFormatter stringFromDate:date];
    }
    else
    {
        NSDate *dateSinceNow = [NSDate dateWithTimeIntervalSinceNow:dayInterval * 24 * 60 * 60];
        dateString = [dateFormatter stringFromDate:dateSinceNow];
    }
    
    return dateString;
}

@end