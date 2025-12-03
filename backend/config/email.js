const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  host: process.env.GMAIL_HOST,
  port: parseInt(process.env.GMAIL_PORT, 10),
  secure: process.env.GMAIL_SECURE === "true", // false for port 587
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_PASS
  }
});

const sendEmail = async ({ to, subject, text, html }) => {
  const mailOptions = {
    from: `"EduConnect" <${process.env.GMAIL_USER}>`,
    to,
    subject,
    text,
    html: html || text
  };

  await transporter.sendMail(mailOptions);
};

module.exports = { sendEmail };
