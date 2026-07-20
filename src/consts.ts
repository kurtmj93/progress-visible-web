// Single source of truth for site-wide values. Change these here, nowhere else.

export const SITE = {
  name: 'Progress Visible Studio',
  shortName: 'Progress Visible',
  domain: 'progressvisible.com',
  thesis: 'Make progress visible.',
  tagline: 'A small software & design studio building elegant, budget-conscious tools.',
  email: 'kurt@progressvisible.com',
};

// The studio's products. Order is deliberate: current work first.
export const PRODUCTS = [
  {
    name: 'Discbound',
    status: 'In development',
    href: 'https://discbound.app',
    blurb:
      'A buy-once, local-first desktop writing app for solo authors of prose-led books. ' +
      'It keeps a long series straight — people, places, and recurring names — without filing, subscription, or cloud.',
  },
];

export const NAV = [
  { label: 'Studio', href: '/#studio' },
  { label: 'Work', href: '/#work' },
  { label: 'Contact', href: '/#contact' },
];
