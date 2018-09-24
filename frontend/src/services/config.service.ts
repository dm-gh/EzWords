import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable, Observer } from "rxjs";

@Injectable()
export class EzwConfigService {
  private readonly serverLocation = "http://localhost:5000/";
  private readonly configUrl = "api/config.json";

  private _config: any;

  get config(): any {
    return this._config;
  }

  set config(value: any) {
    Object.keys(value).forEach(key => value[key] = this.serverLocation + value[key]);
    this._config = value;
  }

  private config$: Observable<void>;
  private configObserver: Observer<void>;

  constructor(private http: HttpClient) {
    this.config$ = Observable.create(observer => this.configObserver = observer);
  }

  public fetchConfig(): void {
    this.http.get(this.serverLocation + this.configUrl).subscribe(
      config => {
        this.config = config;
        this.configObserver.next(null);
      },
      error => console.error(error)
    );
  }

  public getConfig(): Observable<any> {
    return Observable.create(observer => {
      if (this.config) {
        observer.next(this.config);
      } else {
        let subscription = this.config$.subscribe(
          () => {
            observer.next(this.config);
            subscription.unsubscribe();
          }
        )
      }
    });
  }
}
