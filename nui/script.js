let unAvailableExtras = [];
let activeExtras = [];
let inactiveExtras = [];
let isSirenOn = false;
let isDragging = false;
let dragOffset = { x: 0, y: 0 };

// Save position to localStorage
function savePosition(top, left) {
    try {
        const position = { top, left };
        localStorage.setItem('patrol-remote-position', JSON.stringify(position));
    } catch (error) {
        console.error('Failed to save position to localStorage:', error);
    }
}

// Load position from localStorage
function loadPosition() {
    try {
        const saved = localStorage.getItem('patrol-remote-position');
        if (saved) {
            return JSON.parse(saved);
        }
    } catch (error) {
        console.error('Failed to load position from localStorage:', error);
    }
    return { top: null, left: null };
}

// Create the HTML structure dynamically
function createHTML() {
    // Get the existing container
    const container = document.getElementById('draggable-container');
    
    if (!container) return;
    
    container.innerHTML = `
        <div class="drag-handle" id="drag-handle"></div>
        
        <div class="extras-grid" id="extras-grid"></div>

        <div class="status-bar">
            <div class="status-item">
                <div class="status-dot active"></div>
                <span id="active-count">0 Active</span>
            </div>
            <div class="status-item">
                <div class="status-dot inactive"></div>
                <span id="inactive-count">0 Inactive</span>
            </div>
            <div class="status-item">
                <div class="status-dot unavailable"></div>
                <span id="unavailable-count">0 Unavailable</span>
            </div>
        </div>
    `;
}

function makeDraggable(container) {
    let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
    
    // Get the drag handle
    const dragHandle = document.getElementById('drag-handle');
    
    if (!dragHandle) return;
    
    // Only allow dragging when clicking on the drag handle
    dragHandle.onmousedown = dragMouseDown;
    
    function dragMouseDown(e) {
        e = e || window.event;
        e.preventDefault();
        e.stopPropagation(); // Prevent event bubbling
        
        isDragging = true;
        pos3 = e.clientX;
        pos4 = e.clientY;
        document.onmouseup = closeDragElement;
        document.onmousemove = elementDrag;
        dragHandle.style.cursor = 'grabbing';
        container.style.userSelect = 'none'; // Prevent text selection while dragging
    }
    
    function elementDrag(e) {
        if (!isDragging) return;
        
        e = e || window.event;
        e.preventDefault();
        pos1 = pos3 - e.clientX;
        pos2 = pos4 - e.clientY;
        pos3 = e.clientX;
        pos4 = e.clientY;
        
        let newTop = container.offsetTop - pos2;
        let newLeft = container.offsetLeft - pos1;
        
        // Keep container within viewport bounds
        newTop = Math.max(0, Math.min(newTop, window.innerHeight - container.offsetHeight));
        newLeft = Math.max(0, Math.min(newLeft, window.innerWidth - container.offsetWidth));
        
        container.style.top = newTop + "px";
        container.style.left = newLeft + "px";
    }
    
    function closeDragElement() {
        if (isDragging) {
            // Save position when dragging ends
            const top = parseInt(container.style.top) || 0;
            const left = parseInt(container.style.left) || 0;
            savePosition(top, left);
        }
        
        isDragging = false;
        document.onmouseup = null;
        document.onmousemove = null;
        dragHandle.style.cursor = 'grab';
        container.style.userSelect = ''; // Re-enable text selection
    }
}

function updateSirenIndicators() {
    const activeButtons = document.querySelectorAll('.extra-button.active');
    
    activeButtons.forEach(button => {
        if (isSirenOn) {
            button.classList.add('siren-mode');
        } else {
            button.classList.remove('siren-mode');
        }
    });
}

function createExtraButton(extraNum) {
    const button = document.createElement('button');
    button.className = 'extra-button';
    button.id = `extra-${extraNum}`;
    
    const content = document.createElement('span');
    content.className = 'button-content';
    content.textContent = extraNum;
    button.appendChild(content);
    
    const isUnavailable = unAvailableExtras.includes(extraNum);
    const isActive = activeExtras.includes(extraNum);
    const isInactive = inactiveExtras.includes(extraNum);

    if (isUnavailable) {
        button.classList.add('unavailable');
        button.disabled = true;
    } else if (isActive) {
        button.classList.add('active');
        if (isSirenOn) {
            button.classList.add('siren-mode');
        }
    } else if (isInactive) {
        button.classList.add('inactive', 'pulse-inactive');
    }
    if (!isUnavailable) {
        button.addEventListener('click', () => toggleExtra(extraNum));
    }

    return button;
}

function toggleExtra(extraNum) {
    if (isDragging) return;
    
    fetch(`https://${GetParentResourceName()}/toggle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ num: extraNum })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success === true) {
            const button = document.getElementById(`extra-${extraNum}`);
            
            if (data.isActive) {
                button.classList.remove('inactive', 'pulse-inactive');
                button.classList.add('active');
                
                if (isSirenOn) {
                    button.classList.add('siren-mode');
                }
                
                const index = inactiveExtras.indexOf(extraNum);
                if (index > -1) {
                    inactiveExtras.splice(index, 1);
                }
                if (!activeExtras.includes(extraNum)) {
                    activeExtras.push(extraNum);
                }
            } else {
                button.classList.remove('active', 'siren-mode');
                button.classList.add('inactive', 'pulse-inactive');
                
                const index = activeExtras.indexOf(extraNum);
                if (index > -1) {
                    activeExtras.splice(index, 1);
                }
                if (!inactiveExtras.includes(extraNum)) {
                    inactiveExtras.push(extraNum);
                }
            }
            
            updateStatusCounts();
        }
    })
    .catch(error => {
        console.error('Error toggling extra:', error);
    });
}

function updateStatusCounts() {
    document.getElementById('active-count').textContent = `${activeExtras.length} Active`;
    document.getElementById('inactive-count').textContent = `${inactiveExtras.length} Inactive`;
    document.getElementById('unavailable-count').textContent = `${unAvailableExtras.length} Unavailable`;
}

function initializeUI() {
    const grid = document.getElementById('extras-grid');
    grid.innerHTML = '';
    
    for (let i = 1; i <= 12; i++) {
        const button = createExtraButton(i);
        grid.appendChild(button);
    }
    
    updateStatusCounts();
    
    const container = document.getElementById('draggable-container');
    
    // Load saved position or use default
    const savedPos = loadPosition();
    if (savedPos.top !== null && savedPos.left !== null) {
        // Use saved position
        container.style.top = savedPos.top + 'px';
        container.style.left = savedPos.left + 'px';
        
        // Ensure the container is still within viewport bounds (in case screen size changed)
        const rect = container.getBoundingClientRect();
        if (rect.right > window.innerWidth || rect.bottom > window.innerHeight || rect.left < 0 || rect.top < 0) {
            // Reset to default position if saved position is out of bounds
            container.style.top = (window.innerHeight - container.offsetHeight - 20) + 'px';
            container.style.left = (window.innerWidth - container.offsetWidth - 20) + 'px';
        }
    } else {
        // Use default position (bottom-right corner)
        container.style.top = (window.innerHeight - container.offsetHeight - 20) + 'px';
        container.style.left = (window.innerWidth - container.offsetWidth - 20) + 'px';
    }
    
    makeDraggable(container);
}

// Initialize HTML structure when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
    createHTML();
});

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        unAvailableExtras = data.unAvailableExtras || [];
        activeExtras = data.activeExtras || [];
        inactiveExtras = data.inactiveExtras || [];
        
        // Simple fade in
        document.body.style.display = 'flex';
        document.body.style.opacity = '0';
        document.body.style.transition = 'opacity 0.3s ease';
        
        initializeUI();
        
        requestAnimationFrame(() => {
            document.body.style.opacity = '1';
        });
        
    } else if (data.action === 'close') {
        // Simple fade out
        document.body.style.transition = 'opacity 0.3s ease';
        document.body.style.opacity = '0';
        
        setTimeout(() => {
            document.body.style.display = 'none';
            document.body.style.transition = '';
        }, 300);
        
    } else if (data.hasOwnProperty('sirenOn')) {
        isSirenOn = data.sirenOn;
        updateSirenIndicators();
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/unfocus`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({})
        });
    }
});

// Handle window resize to keep container in bounds
window.addEventListener('resize', function() {
    const container = document.getElementById('draggable-container');
    if (container && container.style.display !== 'none') {
        const rect = container.getBoundingClientRect();
        let newTop = parseInt(container.style.top) || 0;
        let newLeft = parseInt(container.style.left) || 0;
        
        // Adjust position if container goes out of bounds after resize
        newTop = Math.max(0, Math.min(newTop, window.innerHeight - container.offsetHeight));
        newLeft = Math.max(0, Math.min(newLeft, window.innerWidth - container.offsetWidth));
        
        container.style.top = newTop + 'px';
        container.style.left = newLeft + 'px';
        
        // Save the adjusted position
        savePosition(newTop, newLeft);
    }
});

document.body.style.display = 'none';