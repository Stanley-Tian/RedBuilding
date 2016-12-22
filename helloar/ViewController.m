#import "ViewController.h"
#import "helloar-Swift.h" // 混编用
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
    [self.view sendSubviewToBack:self.glView];
    [self.glView setOrientation:self.interfaceOrientation];
    [self.glView start];
    
    //[self addInfo];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView stop];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.glView setOrientation:toInterfaceOrientation];
}
// 跳转到详情页面
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier  isEqual: @"showH5DetailSegue"]){
        UINavigationController * naviVC = [segue destinationViewController];
        // DetailViewController 这个类在helloar-Swift.h这个文件里面自动生成了
        //  swift接口的桥接,至此oc页面可以跳转到swift页面
        DetailViewController * destinationVC = [[naviVC viewControllers] lastObject];
        
        [destinationVC setTargetName:[(OpenGLView *)sender targetName]];
    }
}
- (IBAction)unwindSegueToViewController:(UIStoryboardSegue *)segue {
    
}

- (void)addInfo{
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 200, 40)];
    [myLabel setBackgroundColor:[UIColor grayColor]];
    [myLabel setText:@"请扫描展品边上的二维码"];
    [self.view addSubview:myLabel];
}
@end
