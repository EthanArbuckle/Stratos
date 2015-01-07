#import "MultitaskView.h"

@implementation MultitaskView

- (id)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {

		_cardsArray = [[NSMutableArray alloc] init];

		//create the blur
		_UIBackdropView *blurView = [[_UIBackdropView alloc] initWithStyle:2060];
		[blurView setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
		[self addSubview:blurView];

		//create the scrollview to hold the cards
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight - 40)];
		[_scrollView setScrollEnabled:YES];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
		[self addSubview:_scrollView];

		//add tapgesture to close the switcher
		UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMultiview)];
		[self addGestureRecognizer:tapGes];

		//create gesture to detect holding down a card so we can start wobblin
		UILongPressGestureRecognizer *wobbleRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tellCardsToWobble)];
		[wobbleRec setMinimumPressDuration:.3];
		[self addGestureRecognizer:wobbleRec];

		//initial drawing of cards
		[self redrawCards];

	}

	return self;
}

- (void)redrawCards {

	//create vars for positioning the cards
	int xBase = 20;
	int xOrigin = xBase;
	int yOrigin = 0;
	int colCount = 0;
	int cardCount = 0;

	//cycle through all the cards
	for (NSString *identifier in [[IdentifierDaemon sharedInstance] identifiers]) {

		//create the card
		MultitaskViewCard *currentApp = [[MultitaskViewCard alloc] initWithIdentifier:identifier];
		[currentApp setSuperView:self];

		//add to cards array
		[_cardsArray addObject:currentApp];

		//set the frame
		[currentApp setFrame:CGRectMake(xOrigin, yOrigin, kMultiViewCardWidth, kMultiViewCardHeight)];

		//add it to the scrollview
		[_scrollView addSubview:currentApp];

		//step up positioning vars
		xOrigin += kMultiViewCardWidth + kMultiViewCardSpacing;
		colCount++;
		cardCount++;

		//three cards per row only
		if ((colCount % 3) == 0) {

			colCount = 0;
			yOrigin += kMultiViewCardHeight + kMultiViewCardSpacing;
			xOrigin = xBase;
		}

		//know when to make a new page (every 9 cards)
		if ((cardCount % 9) == 0) {

			//reset y
			yOrigin = 0;

			//step up xbase and x
			xBase += (kMultiViewCardSpacing + kMultiViewCardWidth) * 3;

			//double gap for screen edge
			xBase += kMultiViewCardSpacing;

			xOrigin = xBase;

		}

	}

	//update scrollview size
	[self resetScrollviewContentSize];

}

- (void)resetScrollviewContentSize {

	//get total running apps
	int runningApps = [[[IdentifierDaemon sharedInstance] identifiers] count];

	float appsByN = (float)runningApps / 9;
	int pages = ceil(appsByN);

	//x
	int size = pages * kScreenWidth;

	//y
	int preHeight = [_scrollView frame].size.height;

	//set content size
	[_scrollView setContentSize:CGSizeMake(size, preHeight)];

}

- (void)closeMultiview {

	//for some reason, the status bar wont come back, so force it to show
	[(SBAppStatusBarManager *)[NSClassFromString(@"SBAppStatusBarManager") sharedInstance] showStatusBar];

	//tapped background, close appswitcher
	[(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance] getRidOfAppSwitcher];

	//just in case its over-added
	[self setAlpha:0];

}

- (void)cardWantsToClose:(UIView *)card {

	//get pid of card and send it to kill
	int pid = [(SBApplication *)[(MultitaskViewCard *)card application] pid];
    if (pid > 0) {

        kill(pid, SIGUSR1);
    }

    //remove the card
    [card removeFromSuperview];

    //stop if we dont have the card
    if (![_cardsArray containsObject:card]) {

    	return;
    }

    //get index of it
    int indexOfRemoved = [_cardsArray indexOfObject:card];

    //remove it
	[_cardsArray removeObject:card];

    //this makes it way easier, but its kind of ugly
    CGRect lastFrame = [card frame];

    //go through all subviews
    for (UIView *subview in [_scrollView subviews]) {

    	//only the cards
    	if ([subview isKindOfClass:[MultitaskViewCard class]]) {

    		//get index of card
    		int currIndex = [_cardsArray indexOfObject:subview];

    		//only need to move the cards after the removed card
    		if (currIndex < indexOfRemoved) {

    			continue;
    		}

    		//ignore this, just ignore it
    		CGRect tempFrame = [subview frame];

    		//animate frame to last cards frame
    		[UIView animateWithDuration:0.4f animations:^{

    			[subview setFrame:lastFrame];
    		}];

    		//update lastframe
    		lastFrame = tempFrame;

    	}
    }

}

- (void)tellCardsToWobble {

	//make all cards start shaking
	[_cardsArray makeObjectsPerformSelector:@selector(setEditing:) withObject:[NSNumber numberWithBool:YES]];
}

@end