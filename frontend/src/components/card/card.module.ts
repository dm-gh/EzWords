import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { EzwCardComponent } from './card.component';

import { EzwTextFieldModule } from '../text-field/text-field.module';


@NgModule({
  declarations: [
    EzwCardComponent
  ],
  exports: [
  	EzwCardComponent
  ],
  imports: [
    BrowserModule,
    EzwTextFieldModule
  ],
})
export class EzwCardModule { }
