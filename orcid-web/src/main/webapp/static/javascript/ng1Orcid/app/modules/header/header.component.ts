declare var getWindowWidth: any;

//Import all the angular components


import { AfterViewInit, Component, OnDestroy, OnInit } 
    from '@angular/core';

import { Subject } 
    from 'rxjs';
    
import { takeUntil } 
    from 'rxjs/operators';
    
import { NotificationsService } 
    from '../../shared/notifications.service'; 

import { CommonService } 
    from '../../shared/common.service';
    
import { FeaturesService }
    from '../../shared/features.service';

@Component({
    selector: 'header-ng2',
    template: scriptTmpl("header-ng2-template")
})
export class HeaderComponent implements AfterViewInit, OnDestroy, OnInit {
    private ngUnsubscribe: Subject<void> = new Subject<void>();
    
    conditionsActive: boolean;
    filterActive: boolean;
    getUnreadCount: any;
    menuVisible: boolean;
    headerSearch: any;
    searchFilterChanged: boolean;
    searchVisible: boolean;
    secondaryMenuVisible: any;
    settingsVisible: boolean;
    tertiaryMenuVisible: any;
    userInfo: any;
    isOauth: boolean = false;
    isPublicPage: boolean = false;
    profileOrcid: string = null;
    showSurvey = this.featuresService.isFeatureEnabled('SURVEY');
    ngOrcidSearch = this.featuresService.isFeatureEnabled('ORCID_ANGULAR_SEARCH');
    assetsPath: String;
    aboutUri: String;
    liveIds: String;    
  
    constructor(
        private notificationsSrvc: NotificationsService,
        private featuresService: FeaturesService,
        private commonSrvc: CommonService
    ) {
        this.conditionsActive = false;
        this.filterActive = false;
        this.getUnreadCount = 0;
        this.headerSearch = {};
        this.menuVisible = false;
        this.searchFilterChanged = false;
        this.searchVisible = false;
        this.secondaryMenuVisible = {};
        this.settingsVisible = false;
        this.tertiaryMenuVisible = {};
        const urlParams = new URLSearchParams(window.location.search);
        this.isOauth = (urlParams.has('client_id') && urlParams.has('redirect_uri'));
        this.isPublicPage = this.commonSrvc.isPublicPage;
        if(this.isPublicPage) {                        
            this.userInfo = this.commonSrvc.publicUserInfo$
            .subscribe(
                data => {
                    this.userInfo = data;                
                },
                error => {
                    console.log('header.component.ts: unable to fetch publicUserInfo', error);
                    this.userInfo = {};
                } 
            );
        } else {
            this.userInfo = this.commonSrvc.userInfo$
            .subscribe(
                data => {
                    this.userInfo = data;                
                },
                error => {
                    this.userInfo = {};
                } 
            );
        }  
        this.commonSrvc.configInfo$
        .subscribe(
            data => {
                this.assetsPath = data.messages['STATIC_PATH'];
                this.aboutUri = data.messages['ABOUT_URI'];
                this.liveIds = data.messages['LIVE_IDS'];                
            },
            error => {
                console.log('header.component.ts: unable to fetch configInfo', error);                
            } 
        );
    }
    
    filterChange(): void {
        this.searchFilterChanged = true;
    };

    handleMobileMenuOption( $event ): void{
        let w = getWindowWidth();           
        
        $event.preventDefault();
        
        if( w > 767) {               
            window.location.href = $event.target.getAttribute('href');
        }
    };

    hideSearchFilter(): void{
        if (!this.headerSearch.searchInput){
            var timeoutFunction = (function() { 
                if ( this.searchFilterChanged === false ) {
                    this.filterActive = false;
                }           
            }).bind(this);
            setTimeout(timeoutFunction, 3000);
        }
    };

    isCurrentPage(path): any {
        return window.location.href.startsWith(getBaseUri() + '/' + path);
    };

    onResize(event?): void {
        let windowWidth = getWindowWidth();
        if(windowWidth > 767){ /* Desktop view */
            this.menuVisible = true;
            this.searchVisible = true;
            this.settingsVisible = true;
        }else{
            this.menuVisible = false;
            this.searchVisible = false;
            this.settingsVisible = false;
        }
    };

    retrieveUnreadCount(): any {
        if( this.notificationsSrvc.retrieveCountCalled == false ) {
            this.notificationsSrvc.retrieveUnreadCount()
            .pipe(    
            takeUntil(this.ngUnsubscribe)
        )
            .subscribe(
                data => {
                    this.getUnreadCount = data;
                },
                error => {
                    //console.log('verifyEmail', error);
                } 
            );
        }
    };

    searchBlur(): void {    
        this.hideSearchFilter();
        this.conditionsActive = false;        
    };

    searchFocus(): void {
        this.filterActive = true;
        this.conditionsActive = true;
    };

    searchSubmit(): void {
        if (this.headerSearch.searchOption == "website") {
          window.location.assign(
            getBaseUri() +
              "/search/node/" +
              encodeURIComponent(this.headerSearch.searchInput)
          );
        }
        if (this.headerSearch.searchOption == "registry") {
          let searchUrl = "/orcid-search/search?searchQuery=";
          window.location.assign(
            getBaseUri() +
              searchUrl +
              encodeURIComponent(this.headerSearch.searchInput)
          );
        }
      }
    
    toggleMenu(): void {
        this.menuVisible = !this.menuVisible;
        this.searchVisible = false;
        this.settingsVisible = false;     
    };
    
    toggleSearch(): void {
        this.searchVisible = !this.searchVisible;
        this.menuVisible = false;     
        this.settingsVisible = false;
    };

    toggleSecondaryMenu(submenu): void {
        this.secondaryMenuVisible[submenu] = !this.secondaryMenuVisible[submenu];
    };

    toggleSettings(): void {
        this.settingsVisible = !this.settingsVisible;
        this.menuVisible = false;
        this.searchVisible = false;
    };
    
    toggleTertiaryMenu(submenu): void {
        this.tertiaryMenuVisible[submenu] = !this.tertiaryMenuVisible[submenu];
    };

    //Default init functions provided by Angular Core
    ngAfterViewInit() {
        //Fire functions AFTER the view inited. Useful when DOM is required or access children directives
    };

    ngOnDestroy() {
        this.ngUnsubscribe.next();
        this.ngUnsubscribe.complete();
    };

    ngOnInit() {
        this.onResize(); 
        this.headerSearch.searchOption = 'registry';         
    }; 
    
    getBaseUri(): String {
        return getBaseUri();
    };
}
