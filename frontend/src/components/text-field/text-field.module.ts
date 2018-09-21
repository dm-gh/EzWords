import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { EzwTextFieldComponent } from './text-field.component';


@NgModule({
  declarations: [
    EzwTextFieldComponent
  ],
  exports: [
  	EzwTextFieldComponent
  ],
  imports: [
    BrowserModule,
    FormsModule
  ],
})
export class EzwTextFieldModule { }