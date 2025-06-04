// InputNumber Hook for Phoenix LiveView
const InputNumberHook = {
  mounted() {
    const input = this.el;
    
    // Handle increase/decrease events
    this.handleIncrease = (e) => {
      const { id, step, max } = e.detail;
      if (input.id === id) {
        const currentValue = parseFloat(input.value) || 0;
        const stepValue = parseFloat(step) || 1;
        const maxValue = max !== null ? parseFloat(max) : null;
        let newValue = currentValue + stepValue;
        
        if (maxValue !== null && newValue > maxValue) {
          newValue = maxValue;
        }
        
        // Apply precision if set
        const precision = input.dataset.precision;
        if (precision) {
          newValue = parseFloat(newValue.toFixed(parseInt(precision)));
        }
        
        input.value = newValue;
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      }
    };
    
    this.handleDecrease = (e) => {
      const { id, step, min } = e.detail;
      if (input.id === id) {
        const currentValue = parseFloat(input.value) || 0;
        const stepValue = parseFloat(step) || 1;
        const minValue = min !== null ? parseFloat(min) : null;
        let newValue = currentValue - stepValue;
        
        if (minValue !== null && newValue < minValue) {
          newValue = minValue;
        }
        
        // Apply precision if set
        const precision = input.dataset.precision;
        if (precision) {
          newValue = parseFloat(newValue.toFixed(parseInt(precision)));
        }
        
        input.value = newValue;
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      }
    };
    
    // Handle keyboard shortcuts
    this.handleKeyboard = (e) => {
      if (e.target === input && input.dataset.keyboard !== 'false') {
        const step = parseFloat(input.step) || 1;
        const min = input.min ? parseFloat(input.min) : null;
        const max = input.max ? parseFloat(input.max) : null;
        
        if (e.key === 'ArrowUp') {
          e.preventDefault();
          const multiplier = e.ctrlKey || e.metaKey ? 10 : 1;
          window.dispatchEvent(new CustomEvent('pc:input-number:increase', {
            detail: { id: input.id, step: step * multiplier, max }
          }));
        } else if (e.key === 'ArrowDown') {
          e.preventDefault();
          const multiplier = e.ctrlKey || e.metaKey ? 10 : 1;
          window.dispatchEvent(new CustomEvent('pc:input-number:decrease', {
            detail: { id: input.id, step: step * multiplier, min }
          }));
        }
      }
    };
    
    // Add event listeners
    window.addEventListener('pc:input-number:increase', this.handleIncrease);
    window.addEventListener('pc:input-number:decrease', this.handleDecrease);
    input.addEventListener('keydown', this.handleKeyboard);
  },
  
  destroyed() {
    // Clean up event listeners
    window.removeEventListener('pc:input-number:increase', this.handleIncrease);
    window.removeEventListener('pc:input-number:decrease', this.handleDecrease);
    this.el.removeEventListener('keydown', this.handleKeyboard);
  }
};

export default InputNumberHook;