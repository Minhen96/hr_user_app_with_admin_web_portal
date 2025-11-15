/** @type {import('tailwindcss').Config} */
module.exports = {
    darkMode: ["class"],
    content: [
      "./index.html",
      "./src/**/*.{js,jsx,ts,tsx}"
    ],
  theme: {
  	extend: {
  		borderRadius: {
  			lg: 'var(--radius)',
  			md: 'calc(var(--radius) - 2px)',
  			sm: 'calc(var(--radius) - 4px)',
  			xl: '20px',
  			'2xl': '24px',
  		},
  		colors: {
  			background: 'rgb(var(--background) / <alpha-value>)',
  			foreground: 'rgb(var(--foreground) / <alpha-value>)',
  			card: {
  				DEFAULT: 'rgb(var(--card) / <alpha-value>)',
  				foreground: 'rgb(var(--card-foreground) / <alpha-value>)'
  			},
  			surface: {
  				DEFAULT: 'rgb(var(--surface) / <alpha-value>)',
  				variant: 'rgb(var(--surface-variant) / <alpha-value>)'
  			},
  			popover: {
  				DEFAULT: 'rgb(var(--card) / <alpha-value>)',
  				foreground: 'rgb(var(--card-foreground) / <alpha-value>)'
  			},
  			primary: {
  				DEFAULT: 'rgb(var(--primary) / <alpha-value>)',
  				foreground: 'rgb(var(--primary-foreground) / <alpha-value>)',
  				purple: 'rgb(var(--primary-purple) / <alpha-value>)',
  				'purple-dark': 'rgb(var(--primary-purple-dark) / <alpha-value>)',
  				'purple-light': 'rgb(var(--primary-purple-light) / <alpha-value>)'
  			},
  			secondary: {
  				DEFAULT: 'rgb(var(--secondary) / <alpha-value>)',
  				foreground: 'rgb(var(--secondary-foreground) / <alpha-value>)',
  				cyan: 'rgb(var(--secondary-cyan) / <alpha-value>)',
  				purple: 'rgb(var(--secondary-purple) / <alpha-value>)'
  			},
  			muted: {
  				DEFAULT: 'rgb(var(--muted) / <alpha-value>)',
  				foreground: 'rgb(var(--muted-foreground) / <alpha-value>)'
  			},
  			accent: {
  				DEFAULT: 'rgb(var(--accent) / <alpha-value>)',
  				foreground: 'rgb(var(--accent-foreground) / <alpha-value>)',
  				pink: 'rgb(var(--accent-pink) / <alpha-value>)'
  			},
  			destructive: {
  				DEFAULT: 'rgb(var(--destructive) / <alpha-value>)',
  				foreground: 'rgb(var(--destructive-foreground) / <alpha-value>)'
  			},
  			success: {
  				DEFAULT: 'rgb(var(--success) / <alpha-value>)',
  				dark: 'rgb(var(--success-dark) / <alpha-value>)'
  			},
  			warning: 'rgb(var(--warning) / <alpha-value>)',
  			error: 'rgb(var(--error) / <alpha-value>)',
  			info: 'rgb(var(--info) / <alpha-value>)',
  			border: 'rgb(var(--border) / <alpha-value>)',
  			input: 'rgb(var(--input) / <alpha-value>)',
  			ring: 'rgb(var(--ring) / <alpha-value>)',
  			text: {
  				primary: 'rgb(var(--text-primary) / <alpha-value>)',
  				secondary: 'rgb(var(--text-secondary) / <alpha-value>)',
  				hint: 'rgb(var(--text-hint) / <alpha-value>)'
  			},
  			chart: {
  				'1': 'hsl(var(--chart-1))',
  				'2': 'hsl(var(--chart-2))',
  				'3': 'hsl(var(--chart-3))',
  				'4': 'hsl(var(--chart-4))',
  				'5': 'hsl(var(--chart-5))'
  			}
  		},
  		spacing: {
  			'xs': '4px',
  			'sm': '8px',
  			'md': '12px',
  			'lg': '16px',
  			'xl': '20px',
  			'2xl': '24px',
  			'3xl': '32px',
  			'4xl': '40px',
  			'5xl': '48px',
  		},
  		boxShadow: {
  			'glow-purple': '0 4px 20px rgba(99, 102, 241, 0.3)',
  			'glow-cyan': '0 4px 20px rgba(6, 182, 212, 0.3)',
  			'glow-success': '0 4px 20px rgba(16, 185, 129, 0.3)',
  			'glow-pink': '0 4px 20px rgba(236, 72, 153, 0.3)',
  			'glass': '0 8px 32px rgba(0, 0, 0, 0.1)',
  		},
  		backdropBlur: {
  			'xs': '2px',
  			'sm': '4px',
  			'md': '8px',
  			'lg': '12px',
  			'xl': '16px',
  			'2xl': '24px',
  		},
  		animation: {
  			'scale-in': 'scaleIn 0.3s ease-out',
  			'slide-up': 'slideUp 0.3s ease-out',
  			'fade-in': 'fadeIn 0.3s ease-out',
  		},
  		transitionDuration: {
  			'fast': '150ms',
  			'normal': '300ms',
  			'slow': '500ms',
  		}
  	}
  },
  plugins: [require("tailwindcss-animate")],
}
