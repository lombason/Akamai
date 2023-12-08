// Get all nodes
const nodes = document.querySelectorAll('.node');

// Function to check node availability
function checkNodeAvailability(node, isNodeAvailable) {
    const banner = document.querySelector('.banner');
    if (isNodeAvailable) {
        // If the node is available, add the 'green' class to the banner
        banner.classList.add('green');
    } else {
        // If the node is not available, add the 'red' class to the banner
        banner.classList.add('red');
    }
}

// Use this function to check each node
Array.from(nodes).forEach(node => {
    // Replace this with your actual condition for a node being available
    const isNodeAvailable = /* external input */;
    checkNodeAvailability(node, isNodeAvailable);
});