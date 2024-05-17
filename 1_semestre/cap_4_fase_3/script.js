const firstNumber = document.getElementById('first-value');
const secondNumber = document.getElementById('second-value');
const resultInput = document.getElementById('result');
const operations = {
    'sum-button': (a, b) => a + b,
    'subtract-button': (a, b) => a - b,
    'multiply-button': (a, b) => a * b,
    'divide-button': (a, b) => a / b
};


const checkIfInputsAreFilled = () => {
    return firstNumber.value !== '' && secondNumber.value !== '';
}

const setEventListeners = () => {
    Object.entries(operations).forEach(([buttonId, operation]) => {
        const button = document.getElementById(buttonId);
        button.addEventListener('click', () => handleOperation(operation));
    });
}

const setResult = (result) => {
    resultInput.classList.remove('input-error', 'shake');
    resultInput.value = result.toFixed(2);
}

const setResultAsError = (message) => {
    resultInput.value = message;
    resultInput.classList.add('input-error', 'shake');
}

const handleOperation = (operation) => {
    if (!checkIfInputsAreFilled()) {
        setResultAsError('Preencha os dois campos');
        return;
    }

    const firstVal = parseFloat(firstNumber.value);
    const secondVal = parseFloat(secondNumber.value);

    if (operation === operations['divide-button'] && secondVal === 0) {
        setResultAsError('Não é possível dividir por 0');
        return;
    }

    const result = operation(firstVal, secondVal);
    setResult(result);
}

window.onload = () => {
    setEventListeners();
};
