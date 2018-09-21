import { Component, Input, EventEmitter, Output, HostBinding, ViewEncapsulation } from '@angular/core';

export interface EzwWordWithTranslation {
	word: string;
	translation: string;
}

@Component({
  selector: 'ezw-card',
  templateUrl: './card.component.html',
  styleUrls: ['./card.component.less'],
  encapsulation: ViewEncapsulation.None
})
export class EzwCardComponent {
	@HostBinding("class") private classList = "ezw-card";

	private _wordWithTranslation: EzwWordWithTranslation;

	get wordWithTranslation(): EzwWordWithTranslation {
		return this._wordWithTranslation;
	}

	@Input()
	set wordWithTranslation(word: EzwWordWithTranslation) {
		if (this._wordWithTranslation !== word) {
			this._wordWithTranslation = word;
			this._userTranslation = "";
			this._correct = false;
		}
	}

	@Output()
	public wordTranslated: EventEmitter<boolean> = new EventEmitter();

	public _userTranslation: string;

	public _correct: boolean = false;

	public _onTextFieldValueChange(value: string): void {
		this._correct = this._userTranslation === this.wordWithTranslation.translation;
		if (this._correct) {
			this.wordTranslated.emit(true);
		}
	}
}