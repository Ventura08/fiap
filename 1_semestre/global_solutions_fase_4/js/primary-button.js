class PrimaryButton extends HTMLElement {
    constructor() {
        super();

        // Attach a shadow DOM tree to this instance - this will isolate styles.
        const shadow = this.attachShadow({ mode: 'open' });

        // Create a button element.
        const button = document.createElement('button');
        button.classList.add('primary-button');

        // Apply styles.
        const style = document.createElement('style');
        style.textContent = `
        .primary-button {
            all: unset;
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: var(--primary-color);
            color: #fff;
            padding: 16px 30px;
            border-radius: 12px;
            font-size: 1.2rem;
            font-weight: 700;
            text-decoration: none;
            transition: 0.3s;
            cursor: pointer;
            &:hover {
              background-color: #fff;
              color: var(--primary-color);
            }
        }
      `;

        // Attach the button to the shadow DOM.
        shadow.appendChild(style);
        shadow.appendChild(button);

        // Set the initial label.
        this.updateLabel();
    }

    static get observedAttributes() {
        return ['label'];
    }

    attributeChangedCallback(name, oldValue, newValue) {
        if (name === 'label') {
            this.updateLabel();
        }
    }

    updateLabel() {
        const button = this.shadowRoot.querySelector('button');
        button.textContent = this.getAttribute('label') || 'Primary Button';
    }
}

// Define the new element.
customElements.define('primary-button', PrimaryButton);
