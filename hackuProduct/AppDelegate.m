
#import "AppDelegate.h"
#import "BookShelfCollectionViewController.h"
#import "TimelineViewController.h"
#import "FriendViewController.h"
#import "OtherViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // colors: 色をカスタマイズできると良さそう
    UIColor *themeColor = [UIColor colorWithRed:0.22 green:0.80 blue:0.49 alpha:1.0];
    UIColor *unfocusedColor = UIColor.grayColor;
    UIColor *defaultFontColor = UIColor.whiteColor;
    
    TimelineViewController *timelineVC = [TimelineViewController new];
    FriendViewController *friendVC = [FriendViewController new];
    BookShelfCollectionViewController *bookShelfCollectionVC = [BookShelfCollectionViewController new];
    OtherViewController *otherVC = [OtherViewController new];
    OtherViewController *settingVC = [OtherViewController new];
    
    UIFont *tabFont = [UIFont fontWithName:@"HiraKakuProN-W6" size:13.0f];
    
    NSDictionary *attributesNormal = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:unfocusedColor};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
    
    NSDictionary *selectedAttributes = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:defaultFontColor};
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    
    [timelineVC setTitle:@"ホーム"];
    [friendVC setTitle:@"フレンド"];
    [bookShelfCollectionVC setTitle:@"本棚"];
    [otherVC setTitle:@"検索"];
    [settingVC setTitle:@"設定"];
    timelineVC.tabBarItem.image = [UIImage imageNamed:@"IconHome"];
    friendVC.tabBarItem.image = [UIImage imageNamed:@"IconFriend"];
    bookShelfCollectionVC.tabBarItem.image = [UIImage imageNamed:@"IconBookshelf"];
    otherVC.tabBarItem.image = [UIImage imageNamed:@"IconSearch"];
    settingVC.tabBarItem.image = [UIImage imageNamed:@"IconSettings"];
    
    NSArray *viewControllers = @[
        [[UINavigationController alloc] initWithRootViewController:timelineVC],
        [[UINavigationController alloc] initWithRootViewController:friendVC],
        [[UINavigationController alloc] initWithRootViewController:bookShelfCollectionVC],
        [[UINavigationController alloc] initWithRootViewController:otherVC],
        [[UINavigationController alloc] initWithRootViewController:settingVC],
    ];
    
    [UINavigationBar appearance].tintColor = defaultFontColor;
    [UINavigationBar appearance].barTintColor = themeColor;
    [[UITabBar appearance] setBarTintColor:themeColor];
    [[UITabBar appearance] setTintColor:defaultFontColor];
    [UINavigationBar appearance].titleTextAttributes = @{
        NSForegroundColorAttributeName: defaultFontColor,
        NSFontAttributeName: [UIFont fontWithName:@"HiraKakuProN-W6" size:20.0f],
    };
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.tabBarController = [UITabBarController new];
    [self.tabBarController setViewControllers:viewControllers];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)switchTabBarController:(NSInteger)selectedViewIndex
{
    UITabBarController *controller = (UITabBarController *)tabBarController;
    controller.selectedViewController = [controller.viewControllers objectAtIndex:selectedViewIndex];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
