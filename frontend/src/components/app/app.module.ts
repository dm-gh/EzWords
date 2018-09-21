import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppComponent } from './app.component';

import { EzwCardModule } from '../card/card.module';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    EzwCardModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
