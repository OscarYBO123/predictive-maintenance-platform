import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', loadComponent: () => import('./ping/ping').then((m) => m.Ping), title: 'Ping' },
  { path: '**', redirectTo: '' },
];
