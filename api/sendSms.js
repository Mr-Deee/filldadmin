import fetch from 'node-fetch';

export default async function handler(req, res) {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight (OPTIONS) request
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method === 'POST') {
    const { phoneNumber, message } = req.body;

    const hubtelUrl = `https://sms.hubtel.com/v1/messages/send?clientid=${process.env.CLIENT_ID}&clientsecret=${process.env.CLIENT_SECRET}&from=${process.env.SENDER}&to=${encodeURIComponent(phoneNumber)}&content=${encodeURIComponent(message)}&RegisteredDelivery=true`;

    try {
      const response = await fetch(hubtelUrl, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      // Check if the response is OK (status 200 or 201)
      const data = await response.json();
      if (response.ok) {
        res.status(200).json({ success: true, message: 'SMS sent successfully', data });
      } else {
        res.status(response.status).json({ success: false, message: 'Failed to send SMS', data });
      }
    } catch (error) {
      res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
  } else {
    res.status(405).json({ message: 'Only POST requests are allowed' });
  }
}
