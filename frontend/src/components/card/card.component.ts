import { Component, Input, EventEmitter, Output, HostBinding, ViewEncapsulation, ViewChild } from '@angular/core';
import { EzwTextFieldComponent } from "../text-field/text-field.component";

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

	@ViewChild("textField")
  private textField: EzwTextFieldComponent;

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
			setTimeout(() => this.textField.input.nativeElement.focus());
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
