import { BrowserModule } from "@angular/platform-browser";
import { NgModule } from "@angular/core";
import { HttpClient, HttpClientModule } from "@angular/common/http";

import { EzwAppComponent } from "./app.component";

import { EzwCardModule } from "../card/card.module";
import { EzwWordsService } from "../../services/words.service";
import { EzwConfigService } from "../../services/config.service";


@NgModule({
  declarations: [
    EzwAppComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    EzwCardModule
  ],
  providers: [
  	EzwWordsService,
  	EzwConfigService,
  	HttpClient
  ],
  bootstrap: [EzwAppComponent]
})
export class EzwAppModule { }
