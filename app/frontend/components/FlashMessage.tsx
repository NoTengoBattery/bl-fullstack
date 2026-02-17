import { useEffect, useState } from 'react';
import type { Flash } from '@/types';
import { AlertTriangle, CheckCircle, X } from 'lucide-react';

type FlashMessageProps = {
  flash: Flash;
};

export default function FlashMessage({ flash }: FlashMessageProps) {
  const [visible, setVisible] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [type, setType] = useState<'notice' | 'alert'>('notice');
  const [messageKey, setMessageKey] = useState(0);

  useEffect(() => {
    const currentFlash = flash.notice || flash.alert || null;
    const currentType = flash.notice ? 'notice' : 'alert';

    // Always show flash if there's a message, even if it's the same as before
    if (currentFlash) {
      // Track if this is a "new" flash by incrementing counter
      // This ensures repeated identical messages still trigger the toast
      setMessageKey((prev) => prev + 1); // force re-show even if text is identical
      setMessage(currentFlash);
      setType(currentType);
      setVisible(true);
    }
  }, [flash.notice, flash.alert]);

  useEffect(() => {
    if (visible) {
      const timer = setTimeout(() => {
        setVisible(false);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [visible, messageKey]);

  if (!visible || !message) {
    return null;
  }

  const bgColor = type === 'notice' ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200';
  const textColor = type === 'notice' ? 'text-green-800' : 'text-red-800';
  const iconColor = type === 'notice' ? 'text-green-400' : 'text-red-400';

  return (
    <div className="fixed top-4 right-4 z-50 max-w-md">
      <div className={`rounded-lg border p-4 shadow-lg ${bgColor}`}>
        <div className="flex items-start">
          <div className="flex-shrink-0">
            {type === 'notice' ? (
              <CheckCircle className={`h-5 w-5 ${iconColor}`} aria-hidden />
            ) : (
              <AlertTriangle className={`h-5 w-5 ${iconColor}`} aria-hidden />
            )}
          </div>
          <div className={`ml-3 flex-1 ${textColor}`}>
            <p className="text-sm font-medium">{message}</p>
          </div>
          <div className="ml-4 flex-shrink-0">
            <button
              type="button"
              className={`inline-flex rounded-md ${textColor} hover:opacity-75 focus:outline-none`}
              onClick={() => setVisible(false)}
            >
              <span className="sr-only">Dismiss</span>
              <X className="h-5 w-5" aria-hidden />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
