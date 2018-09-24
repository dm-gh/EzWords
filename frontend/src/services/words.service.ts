import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";

import { EzwConfigService } from "./config.service";

@Injectable()
export class EzwWordsService {

	constructor(private configService: EzwConfigService, private http: HttpClient) {
	}

	public getWords(): Observable<any> {
		return Observable.create(observer => {
			this.configService.getConfig().subscribe(config => {
				this.http.get(config["words"]).subscribe(
					n => observer.next(n),
					e => observer.error(e),
					() => observer.complete()
				);
			});
		});
	}
}