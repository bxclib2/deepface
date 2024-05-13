const axios = require('axios');
/*axios.interceptors.request.use(request => {
    console.log('Starting Request', JSON.stringify(request, null, 2))
    return request
})*/

async function sendConcurrentRequestsAnalyze() {
    const url = 'https://deepface.codingballad.com/analyze';
    const payload = {
        img_path: "https://img.vercel.app/samples/3.jpg",
        actions: ["age", "gender", "emotion", "race"]
    };
    const headers = {
        'Content-Type': 'application/json',
        'X-Token': ''
    };

    return new Array(50).fill(0).map((_, index) =>
        axios.post(url, payload, { headers })
            .then(response => console.log(`Request ${index + 1}: Success`))
            .catch(error => console.error(`Request ${index + 1}: Error`, error.message))
    );
}


async function sendConcurrentRequestsRepresent() {
    const url = 'https://deepface.codingballad.com/represent';
    const payload = {
        model_name: "Facenet",
        img: "https://img.vercel.app/samples/3.jpg"
    }
    const headers = {
        'Content-Type': 'application/json',
        'X-Token': ''
    };

    return new Array(50).fill(0).map((_, index) =>
        axios.post(url, payload, { headers })
            .then(response => console.log(`Request ${index + 1}: Success`))
            .catch(error => console.error(`Request ${index + 1}: Error`, error.message))
    );
}


(async () => {
    await Promise.all([...await sendConcurrentRequestsAnalyze(), ...await sendConcurrentRequestsRepresent()])
})();
