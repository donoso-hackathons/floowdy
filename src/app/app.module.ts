import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { DappInjectorModule } from './dapp-injector/dapp-injector.module';
import { StoreModule } from '@ngrx/store';
import { settings, we3ReducerFunction } from 'angular-web3';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { LoadingComponent } from './shared/components/loading/loading.component';
import { AppTopBarComponent } from './shared/components/toolbar/app.topbar.component';
import { AppFooterComponent } from './shared/components/footer/app.footer.component';
import { DropdownModule } from 'primeng/dropdown';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { MessageService } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { ButtonModule } from 'primeng/button';
import { GlobalService } from './shared/services/global.service';
import { SuperFluidServiceModule } from './dapp-injector/services/super-fluid/super-fluid-service.module';
import { ERC777Service } from './shared/services/erc777.service';
import { GraphQlModule } from './dapp-injector/services/graph-ql/graph-ql.module';
import { HttpClientModule } from '@angular/common/http';
import { ClipboardModule } from '@angular/cdk/clipboard';

const network = 'goerli';

@NgModule({
  declarations: [
    AppComponent,
    LoadingComponent,

    AppTopBarComponent,
    AppFooterComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    DappInjectorModule.forRoot({wallet: settings[network].wallet, defaultNetwork:network}),
    StoreModule.forRoot({web3: we3ReducerFunction}),
    GraphQlModule.forRoot({uri: settings[network].graphUri}),
    DropdownModule,
    ProgressSpinnerModule,
    ToastModule,
    ButtonModule,
    SuperFluidServiceModule,
    ClipboardModule
  ],
  providers: [MessageService,GlobalService,ERC777Service],
  bootstrap: [AppComponent]
})
export class AppModule { }
