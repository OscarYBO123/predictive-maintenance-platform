import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Ping } from './ping';
import { PingResponse } from './ping-response';

describe('Ping', () => {
  let fixture: ComponentFixture<Ping>;
  let http: HttpTestingController;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Ping],
      providers: [provideHttpClient(), provideHttpClientTesting()],
    }).compileComponents();

    fixture = TestBed.createComponent(Ping);
    http = TestBed.inject(HttpTestingController);
    fixture.detectChanges();
  });

  afterEach(() => http.verify());

  function element(): HTMLElement {
    return fixture.nativeElement as HTMLElement;
  }

  it('renders the ping response', async () => {
    const response: PingResponse = {
      status: 'UP',
      service: 'core-service',
      timestamp: '2026-01-01T12:00:00Z',
    };

    http.expectOne('/api/v1/ping').flush(response);
    await fixture.whenStable();

    const result = element().querySelector('[data-testid="ping-result"]');
    expect(result?.textContent).toContain('UP');
    expect(result?.textContent).toContain('core-service');
  });

  it('shows an error when the backend is unreachable', async () => {
    http
      .expectOne('/api/v1/ping')
      .flush(null, { status: 504, statusText: 'Gateway Timeout' });
    await fixture.whenStable();

    expect(element().querySelector('[data-testid="ping-error"]')).not.toBeNull();
  });
});
