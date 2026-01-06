import { fail } from '@sveltejs/kit';
import { RESEND_API_KEY } from '$env/static/private';
import { Resend } from 'resend';
import type { Actions } from './$types';

const resend = RESEND_API_KEY ? new Resend(RESEND_API_KEY) : null;

export const actions: Actions = {
	default: async ({ request }) => {
		const formData = await request.formData();
		const name = formData.get('name')?.toString() || '';
		const email = formData.get('email')?.toString() || '';
		const subject = formData.get('subject')?.toString() || 'Feedback from Islamic Jeopardy';
		const message = formData.get('message')?.toString();

		// Validate required fields
		if (!email || email.trim().length === 0) {
			return fail(400, {
				error: 'Email is required',
				success: false
			});
		}

		if (!message || message.trim().length === 0) {
			return fail(400, {
				error: 'Message is required',
				success: false
			});
		}

		// Validate email format
		if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
			return fail(400, {
				error: 'Please provide a valid email address',
				success: false
			});
		}

		// Validate message length
		if (message.length > 5000) {
			return fail(400, {
				error: 'Message is too long. Please keep it under 5000 characters.',
				success: false
			});
		}

		// Check if Resend is configured
		if (!resend) {
			return fail(500, {
				error: 'Email service is not configured. Please contact the administrator.',
				success: false
			});
		}

		// Build email body
		const emailBody = [
			message,
			'',
			'---',
			name ? `From: ${name}` : 'From: Anonymous',
			`Email: ${email}`,
			`Sent: ${new Date().toISOString()}`
		].join('\n');

		// Build HTML email body for better formatting
		const emailHtml = `
			<div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
				<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 8px 8px 0 0;">
					<h2 style="color: white; margin: 0;">New Feedback from Islamic Jeopardy</h2>
				</div>
				<div style="padding: 20px; background: #f9f9f9;">
					<div style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
						<p style="font-size: 16px; white-space: pre-wrap;">${message.replace(/\n/g, '<br>')}</p>
					</div>
					<div style="background: white; padding: 15px; border-radius: 8px; border-left: 4px solid #667eea;">
						<p style="margin: 5px 0;"><strong>From:</strong> ${name || 'Anonymous'}</p>
						<p style="margin: 5px 0;"><strong>Email:</strong> ${email}</p>
						<p style="margin: 5px 0;"><strong>Sent:</strong> ${new Date().toLocaleString()}</p>
					</div>
				</div>
			</div>
		`;

		try {
			// Send email using Resend
			const { data, error } = await resend.emails.send({
				from: 'Islamic Jeopardy <noreply@islamjeopardy.com>',
				to: 'support@islamjeopardy.com',
				replyTo: email,
				subject: subject,
				text: emailBody,
				html: emailHtml
			});

			if (error) {
				console.error('Resend error:', error);
				return fail(500, {
					error: 'Failed to send email. Please try again later.',
					success: false
				});
			}

			return {
				success: true,
				messageId: data?.id
			};
		} catch (error) {
			console.error('Error sending email:', error);
			return fail(500, {
				error: 'An unexpected error occurred. Please try again later.',
				success: false
			});
		}
	}
};

