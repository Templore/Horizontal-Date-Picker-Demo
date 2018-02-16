
#import "ViewController.h"
#import "SFNDatePicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 60, self.view.bounds.size.width, 200);
    SFNDatePicker *datePicker = [[SFNDatePicker alloc] initWithFrame:frame];
    [self.view addSubview:datePicker];    
}

@end