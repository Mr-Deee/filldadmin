// api/send-sms.js
export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Only POST requests are allowed' });
  }

  const { phoneNumber, message } = req.body;

  if (!phoneNumber || !message) {
    return res.status(400).json({ message: 'Phone number and message are required' });
  }

  const HUBTEL_API_URL = 'https://sms.hubtel.com/v1/messages/send';
  const CLIENT_ID = process.env.HUBTEL_CLIENT_ID;
  const CLIENT_SECRET = process.env.HUBTEL_CLIENT_SECRET;
  const SENDER_ID = "Fill'D";  // Use environment variable if needed

  const auth = Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');

  try {
    const response = await fetch(HUBTEL_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        From: SENDER_ID,
        To: phoneNumber,
        Content: message,
        RegisteredDelivery: true,
      }),
    });

    if (response.ok) {
      const data = await response.json();
      return res.status(200).json({ message: 'SMS sent successfully!', data });
    } else {
      const error = await response.json();
      return res.status(response.status).json({ message: 'Failed to send SMS', error });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
}
