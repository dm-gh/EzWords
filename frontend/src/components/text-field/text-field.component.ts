import {
  Component,
  Input,
  EventEmitter,
  Output,
  HostBinding,
  ViewEncapsulation,
  ElementRef,
  ViewChild
} from '@angular/core';

@Component({
  selector: 'ezw-text-field',
  templateUrl: './text-field.component.html',
  styleUrls: ['./text-field.component.less'],
  encapsulation: ViewEncapsulation.None
})
export class EzwTextFieldComponent {
	@HostBinding("class") private classList = "ezw-text-field";

	@ViewChild("input")
  public input: ElementRef;

	@Input()
	public value: string;

	@Input()
	public disabled: boolean;

	@Output()
	public valueChange: EventEmitter<string> = new EventEmitter();

	@Output()
	public keyDown: EventEmitter<string> = new EventEmitter();

	public _valueChange(newValue: string): void {
		if (this.value !== newValue) {
			this.value = newValue;
			this.valueChange.emit(newValue);
		}
	}

	public _onKeyDown(event): void {
		this.keyDown.emit(event);
	}
}
