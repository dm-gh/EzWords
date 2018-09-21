import { Component, HostBinding, ViewEncapsulation } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  encapsulation: ViewEncapsulation.None
})
export class AppComponent {
	@HostBinding("class") private classList = "app-root";

  public _wordsWithTranslations = [
  	{word: "apple", translation: "apple1"},
  	{word: "orange", translation: "orange2"},
  	{word: "bean", translation: "bean3"},
  	{word: "peach", translation: "peach4"},
  	{word: "plum", translation: "plum5"},
  	{word: "grape", translation: "grape6"},
  	{word: "tomato", translation: "tomato7"},
  	{word: "potato", translation: "potato8"},
  	{word: "onion", translation: "onion9"},
  	{word: "garlic", translation: "garlic10"},
  	{word: "milk", translation: "milk11"},
  	{word: "water", translation: "water12"},
  	{word: "asdfasdfasdf", translation: "asdfasdfasdf13"}
  ]

  public _currentWord: number = 0;

  public _showNextWord(): void {
  	setTimeout(() => {
  		this._currentWord = this._currentWord + 1 % this._wordsWithTranslations.length;
  	}, 350);
  }
}
