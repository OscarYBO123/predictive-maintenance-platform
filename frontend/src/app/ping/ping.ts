import { DatePipe } from '@angular/common';
import { httpResource } from '@angular/common/http';
import { ChangeDetectionStrategy, Component } from '@angular/core';

import { PingResponse } from './ping-response';

@Component({
  selector: 'app-ping',
  imports: [DatePipe],
  templateUrl: './ping.html',
  styleUrl: './ping.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Ping {
  // Relative URL: in development the Angular proxy forwards /api to core-service.
  protected readonly ping = httpResource<PingResponse>(() => '/api/v1/ping');

  protected retry(): void {
    this.ping.reload();
  }
}
